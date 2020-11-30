CREATE TABLE [dbo].[MA_Correo] (
    [IdCorreo]         INT            IDENTITY (1, 1) NOT NULL,
    [HTML]             NVARCHAR (MAX) NULL,
    [Descripcion]      NVARCHAR (MAX) NULL,
    [Asunto]           NVARCHAR (MAX) NULL,
    [IdServidor]       INT            NOT NULL,
    [IdCreadoPor]      INT            NULL,
    [IdContrato]       INT            NULL,
    [IdSubcontratista] INT            NULL,
    [CreadoEl]         DATETIME       NULL,
    [ModificadoPor]    INT            NULL,
    [ModificadoEl]     DATETIME       NULL,
    CONSTRAINT [PK_MA_Correo] PRIMARY KEY CLUSTERED ([IdCorreo] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

