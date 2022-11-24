CREATE TABLE [dbo].[IN_Almacen] (
    [IdAlmacen]             INT           NOT NULL,
    [Nombre]                VARCHAR (250) NOT NULL,
    [Clave]                 VARCHAR (10)  NOT NULL,
    [Telefono]              VARCHAR (15)  NOT NULL,
    [Domicilio]             VARCHAR (500) NOT NULL,
    [Email]                 VARCHAR (50)  NOT NULL,
    [UEPS]                  BIT           NOT NULL,
    [Activo]                BIT           NOT NULL,
    [CreadoPor]             INT           NOT NULL,
    [CreadoEl]              DATETIME      NOT NULL,
    [ModificadoPor]         INT           NULL,
    [ModificadoEl]          DATETIME      NULL,
    [IdLineaPresupuestoMes] INT           NULL,
    CONSTRAINT [PK_IN_Almacen] PRIMARY KEY CLUSTERED ([IdAlmacen] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_IN_Almacen_S_Usuario1] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

