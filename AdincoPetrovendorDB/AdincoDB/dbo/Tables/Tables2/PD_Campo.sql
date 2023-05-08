CREATE TABLE [dbo].[PD_Campo] (
    [IdCampo]       INT            IDENTITY (1, 1) NOT NULL,
    [Clave]         NVARCHAR (MAX) NULL,
    [NombreCampo]   NVARCHAR (MAX) NULL,
    [IdYacimiento]  INT            NULL,
    [CreadoPor]     INT            NULL,
    [CreadoEl]      DATETIME       NULL,
    [ModificadoPor] INT            NULL,
    [ModificadoEl]  DATETIME       NULL,
    [Activo]        BIT            NULL,
    CONSTRAINT [PK_PD_Campo] PRIMARY KEY CLUSTERED ([IdCampo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

