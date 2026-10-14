-- Kontaktpersonen für Stelleninserate

CREATE TABLE public.company_contacts (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    company_id uuid NOT NULL
        REFERENCES public.companies(id)
        ON DELETE CASCADE,

    first_name text NOT NULL,
    last_name text NOT NULL,
    position text,
    email text,
    phone text,
    portrait_path text,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT company_contacts_first_name_not_empty
        CHECK (length(btrim(first_name)) > 0),

    CONSTRAINT company_contacts_last_name_not_empty
        CHECK (length(btrim(last_name)) > 0),

    CONSTRAINT company_contacts_id_company_unique
        UNIQUE (id, company_id)
);

CREATE INDEX idx_company_contacts_company_id
    ON public.company_contacts(company_id);


-- Job mit verantwortlicher Person verknüpfen

ALTER TABLE public.jobs
    ADD COLUMN responsible_contact_id uuid;

ALTER TABLE public.jobs
    ADD CONSTRAINT jobs_responsible_contact_company_fk
    FOREIGN KEY (responsible_contact_id, company_id)
    REFERENCES public.company_contacts(id, company_id)
    ON DELETE SET NULL (responsible_contact_id);

CREATE INDEX idx_jobs_responsible_contact_id
    ON public.jobs(responsible_contact_id);


-- Row Level Security aktivieren

ALTER TABLE public.company_contacts
    ENABLE ROW LEVEL SECURITY;



CREATE POLICY "Company members can read own company contacts"
ON public.company_contacts
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1
        FROM public.company_memberships cm
        WHERE cm.company_id = company_contacts.company_id
          AND cm.user_id = (SELECT auth.uid())
    )
);



CREATE POLICY "Company members can create own company contacts"
ON public.company_contacts
FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1
        FROM public.company_memberships cm
        WHERE cm.company_id = company_contacts.company_id
          AND cm.user_id = (SELECT auth.uid())
    )
);


CREATE POLICY "Company members can update own company contacts"
ON public.company_contacts
FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1
        FROM public.company_memberships cm
        WHERE cm.company_id = company_contacts.company_id
          AND cm.user_id = (SELECT auth.uid())
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1
        FROM public.company_memberships cm
        WHERE cm.company_id = company_contacts.company_id
          AND cm.user_id = (SELECT auth.uid())
    )
);



CREATE POLICY "Company members can delete own company contacts"
ON public.company_contacts
FOR DELETE
TO authenticated
USING (
    EXISTS (
        SELECT 1
        FROM public.company_memberships cm
        WHERE cm.company_id = company_contacts.company_id
          AND cm.user_id = (SELECT auth.uid())
    )
);
