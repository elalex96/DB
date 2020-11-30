CREATE TABLE [dbo].[CO_MarcoLegal] (
    [IdMarcoLegal] INT            IDENTITY (1, 1) NOT NULL,
    [MarcoLegal]   NVARCHAR (MAX) NULL,
    [Descripcion]  NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_CO_MarcoLegal] PRIMARY KEY CLUSTERED ([IdMarcoLegal] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

