CREATE TABLE [dbo].[PR_SupervisorZona] (
    [Id]      NCHAR (10) NOT NULL,
    [Usuario] INT        NOT NULL,
    [Zona]    INT        NOT NULL,
    [Estatus] TINYINT    NOT NULL,
    [Inicio]  DATETIME   NOT NULL,
    [Fin]     DATETIME   NOT NULL,
    CONSTRAINT [PK_PR_Supervisor] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Supervisor_Zona] FOREIGN KEY ([Zona]) REFERENCES [dbo].[PR_Zona] ([Id])
);

