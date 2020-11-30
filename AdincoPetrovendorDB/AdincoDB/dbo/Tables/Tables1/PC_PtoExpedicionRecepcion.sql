CREATE TABLE [dbo].[PC_PtoExpedicionRecepcion] (
    [IdPtoExpedicionRecepcion] INT            IDENTITY (10000, 1) NOT NULL,
    [CvPunto]                  NVARCHAR (10)  NULL,
    [Denominacion]             NVARCHAR (MAX) NULL,
    [CreadoPor]                INT            NULL,
    [CreadoEn]                 DATETIME       NULL,
    CONSTRAINT [PK_PC_PtoExpedicionRecepcion] PRIMARY KEY CLUSTERED ([IdPtoExpedicionRecepcion] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

