CREATE TABLE [dbo].[TA_TerminosCondicionesOperacion] (
    [IdOperacionTC]            INT            IDENTITY (1, 1) NOT NULL,
    [IdOperacion]              INT            NOT NULL,
    [IdTerminosYCondiciones]   INT            NOT NULL,
    [TerminosCondicionesTexto] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_TA_TerminosCondicionesOperacion] PRIMARY KEY CLUSTERED ([IdOperacionTC] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_TA_TerminosCondicionesOperacion_TA_Operacion] FOREIGN KEY ([IdOperacion]) REFERENCES [dbo].[TA_Operacion] ([IdOperacion])
);

