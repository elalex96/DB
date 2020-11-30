CREATE TABLE [dbo].[TaTarea] (
    [IdTarea]          INT            IDENTITY (1, 1) NOT NULL,
    [NombreTarea]      NVARCHAR (MAX) NULL,
    [IdTipoTarea]      INT            NULL,
    [FechaRegistro]    DATETIME       NULL,
    [IdEstatus]        INT            NULL,
    [Descripcion]      NVARCHAR (MAX) NULL,
    [IdPrioridad]      INT            NULL,
    [Activo]           BIT            NULL,
    [IdOperacion]      INT            NULL,
    [IdVencimiento]    INT            NULL,
    [idEstadoRegistro] INT            NULL,
    [idUsuarioExterno] INT            NULL,
    [MotivoRechazo]    VARCHAR (MAX)  NULL,
    CONSTRAINT [PK_TaTarea] PRIMARY KEY CLUSTERED ([IdTarea] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__Tarea__IdEstatus] FOREIGN KEY ([IdEstatus]) REFERENCES [dbo].[TaEstatus] ([IdEstatus]),
    CONSTRAINT [FK__Tarea__IdPriorid] FOREIGN KEY ([IdPrioridad]) REFERENCES [dbo].[TaPrioridad] ([IdPrioridad]),
    CONSTRAINT [FK__Tarea__IdTipoTar] FOREIGN KEY ([IdTipoTarea]) REFERENCES [dbo].[TaTipoTarea] ([IdTipoTarea]),
    CONSTRAINT [FK__TaTarea__IdVenci] FOREIGN KEY ([IdVencimiento]) REFERENCES [dbo].[TaVencimiento] ([IdVencimiento]),
    CONSTRAINT [FK_TaTarea_CO_EstadoRegistro] FOREIGN KEY ([idEstadoRegistro]) REFERENCES [dbo].[CO_EstadoRegistro] ([IdEstadoRegistro])
);

