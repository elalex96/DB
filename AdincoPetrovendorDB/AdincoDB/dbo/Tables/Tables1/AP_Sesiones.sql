CREATE TABLE [dbo].[AP_Sesiones] (
    [IdSesion]  INT           IDENTITY (1, 1) NOT NULL,
    [Entrada]   DATETIME      NULL,
    [Salida]    DATETIME      NULL,
    [IdUsuario] INT           NULL,
    [Host]      NVARCHAR (50) NULL,
    [Minutos]   INT           NULL,
    [CreadoPor] INT           NULL,
    CONSTRAINT [PK_Sesiones] PRIMARY KEY CLUSTERED ([IdSesion] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

