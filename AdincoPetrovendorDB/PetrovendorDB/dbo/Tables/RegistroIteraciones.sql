CREATE TABLE [dbo].[RegistroIteraciones] (
    [IdIteracion]       INT            IDENTITY (1, 1) NOT NULL,
    [VersionIteracion]  NVARCHAR (50)  NULL,
    [Modulo]            NVARCHAR (MAX) NULL,
    [IconoModulo]       NVARCHAR (MAX) NULL,
    [FechaRegistro]     DATETIME       NULL,
    [CreadoPor]         INT            NULL,
    [VersionActual]     BIT            NULL,
    [IsEliminado]       BIT            NULL,
    [Aplicacion]        NVARCHAR (50)  NULL,
    [TipoActualizacion] NVARCHAR (MAX) NULL,
    [ModificadoPor]     INT            NULL,
    [ModificadoEl]      DATETIME       NULL,
    CONSTRAINT [PK_RegistroIteraciones] PRIMARY KEY CLUSTERED ([IdIteracion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

