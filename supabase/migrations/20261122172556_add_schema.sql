-- exercise lookup table
CREATE TABLE public.exercises (
    exercise_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exercise_name TEXT NOT NULL
);

-- public.profiles table
CREATE TABLE public.profiles (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT NOT NULL,
    creation_date_and_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- 1-to-1 relationship with users
CREATE TABLE public.workout_goal (
    user_id UUID PRIMARY KEY REFERENCES public.profiles(user_id) ON DELETE CASCADE,
    workout_goal INT NOT NULL,
    CONSTRAINT chk_session_goal CHECK (workout_goal > 0 AND workout_goal < 8)
   
);


CREATE TABLE public.workout_sessions (
    session_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(user_id) ON DELETE CASCADE,
    start_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    end_time TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);

CREATE TABLE public.exercise_log (
    exercise_log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES public.workout_sessions(session_id) ON DELETE CASCADE,
    exercise_id UUID NOT NULL REFERENCES public.exercises(exercise_id) ON DELETE RESTRICT,
    deleted_at TIMESTAMPTZ
);

CREATE TABLE public.set_log (
    set_log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exercise_log_id UUID NOT NULL REFERENCES public.exercise_log(exercise_log_id) ON DELETE CASCADE,
    weight NUMERIC(6, 2) NOT NULL DEFAULT 0,
    repetitions INT NOT NULL DEFAULT 0,
    deleted_at TIMESTAMPTZ
);

-- performance indexes on Foreign Keys
CREATE INDEX idx_workout_sessions_user_id ON public.workout_sessions(user_id);
CREATE INDEX idx_exercise_log_session_id ON public.exercise_log(session_id);
CREATE INDEX idx_exercise_log_exercise_id ON public.exercise_log(exercise_id);
CREATE INDEX idx_set_log_exercise_log_id ON public.set_log(exercise_log_id);

--  Automatically create a profile row when a new user signs up via Supabase Auth
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (user_id, display_name)
    VALUES (
        NEW.id, 
        COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1))
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();