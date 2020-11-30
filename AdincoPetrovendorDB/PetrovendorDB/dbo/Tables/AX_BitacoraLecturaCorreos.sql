CREATE TABLE [dbo].[AX_BitacoraLecturaCorreos] (
    [IdBitacoLecturaCorreos] INT             IDENTITY (1000, 1) NOT NULL,
    [Asunto]                 NVARCHAR (MAX)  NULL,
    [CantidadArchivos]       INT             NULL,
    [FechaLectura]           DATETIME        NULL,
    [FechaEnvio]             DATETIME        NULL,
    [EnviadoPor]             NVARCHAR (1000) NULL,
    [ServicioOperadora]      NVARCHAR (100)  NULL,
    [FechaRegBitacora]       DATETIME        NULL,
    [RecibidoPor]            NVARCHAR (MAX)  NULL,
    [IsError]                BIT             NULL,
    CONSTRAINT [PK_AX_BitacoraLecturaCorreos] PRIMARY KEY CLUSTERED ([IdBitacoLecturaCorreos] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

