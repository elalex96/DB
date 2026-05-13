CREATE TABLE [dbo].[TA_Dominios] (
    [IdDominio]     INT            IDENTITY (1, 1) NOT NULL,
    [IdServidor]    INT            NULL,
    [Identificador] INT            NULL,
    [Activo]        BIT            NULL,
    [Url]           NVARCHAR (MAX) NULL,
    [CreadoPor]     INT            NULL,
    [CreadoEl]      DATETIME       NULL,
    [ModificadoPor] INT            NULL,
    [ModificadoEl]  DATETIME       NULL,
    CONSTRAINT [PK_TA_Dominios]
);

