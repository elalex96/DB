CREATE TABLE [dbo].[CO_RelacionRegistroAdinco] (
    [IdRelacionRegistrosAdinco] INT IDENTITY (1, 1) NOT NULL,
    [IdRegistroPetrovendor]     INT NOT NULL,
    [IdRegistroAdinco]          INT NOT NULL,
    CONSTRAINT [PK_CO_RelacionRegistroAdinco] PRIMARY KEY CLUSTERED ([IdRelacionRegistrosAdinco] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_RelacionRegistroAdinco_CO_Registro1] FOREIGN KEY ([IdRegistroPetrovendor]) REFERENCES [dbo].[CO_Registro] ([IdRegistro])
);

