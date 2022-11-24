CREATE TABLE [dbo].[AP_Modulo] (
    [IdModulo]  INT           IDENTITY (1, 1) NOT NULL,
    [Modulo]    VARCHAR (MAX) NOT NULL,
    [Eliminado] BIT           NOT NULL,
    [CreadoPor] INT           NULL,
    CONSTRAINT [PK_Modulo] PRIMARY KEY CLUSTERED ([IdModulo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

