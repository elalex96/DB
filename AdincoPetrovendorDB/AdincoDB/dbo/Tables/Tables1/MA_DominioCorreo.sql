CREATE TABLE [dbo].[MA_DominioCorreo] (
    [IdDominio]     INT            IDENTITY (1, 1) NOT NULL,
    [Dominio]       NVARCHAR (200) NULL,
    [Sitio]         NVARCHAR (50)  NULL,
    [IdCreadoPor]   INT            NULL,
    [IdEditadorPor] INT            NULL,
    [CreadoEl]      DATETIME       NULL,
    [EditadoPor]    DATETIME       NULL,
    CONSTRAINT [PK_MA_DominioCorreo] PRIMARY KEY CLUSTERED ([IdDominio] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

