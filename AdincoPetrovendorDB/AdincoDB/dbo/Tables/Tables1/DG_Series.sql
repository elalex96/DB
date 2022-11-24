CREATE TABLE [dbo].[DG_Series] (
    [IdSerie]       INT            IDENTITY (1, 1) NOT NULL,
    [IdGrafica]     INT            NULL,
    [Nombre]        VARCHAR (MAX)  NULL,
    [Stack]         NVARCHAR (250) NULL,
    [Color_Stock_0] NVARCHAR (50)  NULL,
    [Color_Stock_1] NVARCHAR (50)  NULL,
    [Type_Serie]    NVARCHAR (50)  NULL,
    [Color_Serie]   NCHAR (10)     NULL,
    [Name]          VARCHAR (MAX)  NULL,
    CONSTRAINT [PK_DG_Series] PRIMARY KEY CLUSTERED ([IdSerie] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

