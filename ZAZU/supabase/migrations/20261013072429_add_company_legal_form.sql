alter table public.companies
    add column legal_form text;

alter table public.companies
    add constraint companies_legal_form_check
    check (
        legal_form is null
        or legal_form in (
            'AG',
            'GmbH',
            'Einzelfirma',
            'Keine Rechtsform'
        )
    );
