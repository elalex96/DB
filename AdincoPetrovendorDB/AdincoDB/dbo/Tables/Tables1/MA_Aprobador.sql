CREATE TABLE [dbo].[MA_Aprobador] (
    [IdAprobador]      INT            IDENTITY (1, 1) NOT NULL,
    [IdOperacion]      INT            NULL,
    [IdLineaTiempo]    INT            NULL,
    [NoSecuencia]      INT            NULL,
    [IdUsuario]        INT            NULL,
    [NombreUsuario]    NVARCHAR (MAX) NULL,
    [IdSubcontratista] INT            NULL,
    [IdTipoOperacion]  INT            NULL,
    [IdContrato]       INT            NULL,
    [CreadoPor]        INT            NULL,
    [CreadoEl]         DATETIME       NULL,
    [ModificadoPor]    INT            NULL,
    [ModificadoEl]     DATETIME       NULL,
    [Correo]           NVARCHAR (150) NULL,
    [EnlaceDetalle]    NVARCHAR (MAX) NULL,
    [EnlaceAprobado]   NVARCHAR (MAX) NULL,
    [EnlaceRechazo]    NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([IdAprobador] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

