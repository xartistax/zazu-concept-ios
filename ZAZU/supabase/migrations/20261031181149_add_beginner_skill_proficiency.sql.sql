begin;

alter table public.candidate_skills
    drop constraint candidate_skills_proficiency_check,
    add constraint candidate_skills_proficiency_check
        check (
            proficiency in (
                'beginner', 'basic', 'good', 'very_good', 'expert'
            )
        );

alter table public.candidate_custom_skills
    drop constraint candidate_custom_skills_proficiency_check,
    add constraint candidate_custom_skills_proficiency_check
        check (
            proficiency in (
                'beginner', 'basic', 'good', 'very_good', 'expert'
            )
        );

alter table public.job_skills
    drop constraint job_skills_minimum_proficiency_check,
    add constraint job_skills_minimum_proficiency_check
        check (
            minimum_proficiency in (
                'beginner', 'basic', 'good', 'very_good', 'expert'
            )
        );

commit;
