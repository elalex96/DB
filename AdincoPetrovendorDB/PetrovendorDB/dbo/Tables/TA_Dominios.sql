CREATE TABLE [dbo].[TA_Dominios] (
    [IdDominio]     INT            IDENTITY (1, 1) NOT NULL,
    [IdServidor]    INT            NULL,
    [Identificador] INT            NULL,
    [Activo]        BIT            NULL,
    [Url]           NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_TA_Dominios] PRIMARY KEY CLUSTERED ([IdDominio] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

