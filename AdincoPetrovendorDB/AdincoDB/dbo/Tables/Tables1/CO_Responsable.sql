CREATE TABLE [dbo].[CO_Responsable] (
    [IdResponsable]     INT            IDENTITY (1, 1) NOT NULL,
    [NombreResponsable] NVARCHAR (MAX) NULL,
    [IdUsuario]         INT            NULL,
    [FecMovto]          DATETIME       NULL,
    [Activo]            BIT            NULL,
    [CreadoPor]         INT            NULL,
    CONSTRAINT [PK_Responsables] PRIMARY KEY CLUSTERED ([IdResponsable] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

