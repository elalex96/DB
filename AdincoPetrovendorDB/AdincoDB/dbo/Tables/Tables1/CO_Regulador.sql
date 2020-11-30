CREATE TABLE [dbo].[CO_Regulador] (
    [IdRegulador]     INT            IDENTITY (1, 1) NOT NULL,
    [Regulador]       NVARCHAR (MAX) NULL,
    [NombreRegulador] NVARCHAR (MAX) NULL,
    [LogoRegulador]   VARCHAR (300)  NULL,
    CONSTRAINT [PK_CO_Regulador] PRIMARY KEY CLUSTERED ([IdRegulador] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

