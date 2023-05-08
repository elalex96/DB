CREATE TABLE [dbo].[AM_OrganoRegulador] (
    [IdOrganoRegulador]     INT            IDENTITY (1, 1) NOT NULL,
    [NombreOrganoRegulador] NVARCHAR (MAX) NULL,
    [CreadoPor]             INT            NULL,
    [CreadoEl]              DATETIME       NULL,
    [ModificadoPor]         INT            NULL,
    [ModificadoEl]          DATETIME       NULL,
    [Activo]                BIT            NULL,
    CONSTRAINT [PK_AM_OrganoRegulador] PRIMARY KEY CLUSTERED ([IdOrganoRegulador] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

