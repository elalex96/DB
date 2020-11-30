CREATE TABLE [dbo].[EN_AreaResponsableEntregable] (
    [IdAreaResponsableEntregable] INT            IDENTITY (1, 1) NOT NULL,
    [AreaResponsable]             NVARCHAR (MAX) NULL,
    [CreadoPor]                   INT            NULL,
    CONSTRAINT [PK_Cat_General_AreaResponsableEntregable] PRIMARY KEY CLUSTERED ([IdAreaResponsableEntregable] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

