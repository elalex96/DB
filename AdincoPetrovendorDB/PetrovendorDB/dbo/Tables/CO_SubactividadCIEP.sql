CREATE TABLE [dbo].[CO_SubactividadCIEP] (
    [IdSubactividad]     INT            IDENTITY (1, 1) NOT NULL,
    [IdActividad]        INT            NULL,
    [ID_CATSUBACTIV]     NVARCHAR (MAX) NULL,
    [NombreSubactividad] NVARCHAR (MAX) NULL,
    [IdTipoServicio]     INT            NULL,
    [IdUsuario]          INT            NULL,
    [FecMovto]           DATETIME       NULL,
    [Activo]             BIT            NULL,
    [CreadoPor]          INT            NULL,
    CONSTRAINT [PK_Subactividades] PRIMARY KEY CLUSTERED ([IdSubactividad] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

