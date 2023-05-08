CREATE TABLE [dbo].[CO_SubTareaPetrolera] (
    [IdSubTareaPetrolera] INT            IDENTITY (10000, 1) NOT NULL,
    [IdContrato]          INT            NULL,
    [id_SubTarea]         NVARCHAR (MAX) NULL,
    [IdServicio]          INT            NULL,
    CONSTRAINT [PK_CO_SubtareaPetrolera] PRIMARY KEY CLUSTERED ([IdSubTareaPetrolera] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_SubTareaPetrolera_CO_Servicio] FOREIGN KEY ([IdServicio]) REFERENCES [dbo].[CO_Servicio] ([IdServicio])
);

