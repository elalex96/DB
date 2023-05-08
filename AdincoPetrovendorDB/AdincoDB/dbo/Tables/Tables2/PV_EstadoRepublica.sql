CREATE TABLE [dbo].[PV_EstadoRepublica] (
    [idEstado] INT           NOT NULL,
    [idPais]   INT           NOT NULL,
    [Estado]   VARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_Cat_Estado] PRIMARY KEY CLUSTERED ([idEstado] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Cat_Estado_Cat_Pais] FOREIGN KEY ([idPais]) REFERENCES [dbo].[PV_PaisRepublica] ([id])
);

