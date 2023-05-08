CREATE TABLE [dbo].[PR_Tanque_Macropera] (
    [IdTanque] INT NOT NULL,
    [IdCampo]  INT NOT NULL,
    PRIMARY KEY CLUSTERED ([IdTanque] ASC, [IdCampo] ASC),
    CONSTRAINT [FK_PR_Tanque_Macropera_PD_Campo] FOREIGN KEY ([IdCampo]) REFERENCES [dbo].[PD_Campo] ([IdCampo]),
    CONSTRAINT [FK_PR_Tanque_Macropera_PR_Tanque] FOREIGN KEY ([IdTanque]) REFERENCES [dbo].[PR_Tanque] ([Id])
);

