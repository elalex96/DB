CREATE TABLE [dbo].[AM_MarcoLegal] (
    [IdMarcoLegal]      INT            IDENTITY (1, 1) NOT NULL,
    [IdOrganoRegulador] INT            NULL,
    [NombreMarcoLegal]  NVARCHAR (MAX) NULL,
    [CreadoPor]         INT            NULL,
    [CreadoEl]          DATETIME       NULL,
    [ModificadoPor]     INT            NULL,
    [ModificadoEl]      DATETIME       NULL,
    [Activo]            BIT            NULL,
    CONSTRAINT [PK_AM_MarcoLegal] PRIMARY KEY CLUSTERED ([IdMarcoLegal] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AM_MarcoLegal_AM_OrganoRegulador] FOREIGN KEY ([IdOrganoRegulador]) REFERENCES [dbo].[AM_OrganoRegulador] ([IdOrganoRegulador])
);

