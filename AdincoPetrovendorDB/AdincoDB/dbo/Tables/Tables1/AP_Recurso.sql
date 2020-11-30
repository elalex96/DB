CREATE TABLE [dbo].[AP_Recurso] (
    [ID]            INT           IDENTITY (1, 1) NOT NULL,
    [RecursoID]     INT           NOT NULL,
    [RecursoNombre] NVARCHAR (50) NOT NULL,
    [Color]         INT           NULL,
    [Image]         IMAGE         NULL,
    CONSTRAINT [PK_Resources] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

