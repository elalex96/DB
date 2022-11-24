CREATE TABLE [dbo].[TaNotificacionTarea] (
    [IdNotificacionTarea] INT IDENTITY (1, 1) NOT NULL,
    [IdVencimiento]       INT NULL,
    [DiaNotificacion]     INT NULL,
    CONSTRAINT [PK_TaNotificacionTarea] PRIMARY KEY CLUSTERED ([IdNotificacionTarea] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__TaNotific__IdVen] FOREIGN KEY ([IdVencimiento]) REFERENCES [dbo].[TaVencimiento] ([IdVencimiento])
);

