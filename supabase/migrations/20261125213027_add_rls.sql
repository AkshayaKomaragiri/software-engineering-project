-- 1. Enable RLS on all your user-specific tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_goal ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exercise_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.set_log ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.exercises ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read exercises" ON public.exercises FOR SELECT USING (true);


-- 2. Profiles Policies
CREATE POLICY "Users can view their own profile" 
    ON public.profiles FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own profile" 
    ON public.profiles FOR UPDATE 
    USING (auth.uid() = user_id);


-- 3. Workout Goal Policies
CREATE POLICY "Users can manage their own workout goals" 
    ON public.workout_goal FOR ALL 
    USING (auth.uid() = user_id) 
    WITH CHECK (auth.uid() = user_id);


-- 4. Workout Sessions Policies
CREATE POLICY "Users can manage their own workout sessions" 
    ON public.workout_sessions FOR ALL 
    USING (auth.uid() = user_id) 
    WITH CHECK (auth.uid() = user_id);


-- 5. Exercise Log Policies (linked via session_id)
CREATE POLICY "Users can manage exercise logs for their own sessions" 
    ON public.exercise_log FOR ALL 
    USING (
        EXISTS (
            SELECT 1 FROM public.workout_sessions 
            WHERE workout_sessions.session_id = exercise_log.session_id 
              AND workout_sessions.user_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.workout_sessions 
            WHERE workout_sessions.session_id = exercise_log.session_id 
              AND workout_sessions.user_id = auth.uid()
        )
    );


-- 6. Set Log Policies (linked via exercise_log_id)
CREATE POLICY "Users can manage set logs for their own exercise logs" 
    ON public.set_log FOR ALL 
    USING (
        EXISTS (
            SELECT 1 FROM public.exercise_log
            JOIN public.workout_sessions ON workout_sessions.session_id = exercise_log.session_id
            WHERE exercise_log.exercise_log_id = set_log.exercise_log_id 
              AND workout_sessions.user_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.exercise_log
            JOIN public.workout_sessions ON workout_sessions.session_id = exercise_log.session_id
            WHERE exercise_log.exercise_log_id = set_log.exercise_log_id 
              AND workout_sessions.user_id = auth.uid()
        )
    );