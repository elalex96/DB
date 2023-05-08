CREATE TABLE [dbo].[IN_AL_Movimiento] (
    [IdMovimiento]          INT           NOT NULL,
    [IdAlmacen]             INT           NOT NULL,
    [IdPedido]              INT           NULL,
    [Folio]                 INT           NOT NULL,
    [IdTipoMovimiento]      TINYINT       NOT NULL,
    [FechaMovimiento]       DATETIME      NOT NULL,
    [HoraMovimiento]        TIME (7)      NOT NULL,
    [RecibidoEn]            VARCHAR (250) NULL,
    [EntregadoEn]           VARCHAR (250) NULL,
    [IdUsuarioAtendio]      INT           NOT NULL,
    [Comentarios]           VARCHAR (550) NOT NULL,
    [PrecioTotal]           MONEY         NOT NULL,
    [IdUsuarioAutorizo]     INT           NULL,
    [FechaAutoriza]         DATETIME      NULL,
    [CreadoPor]             INT           NOT NULL,
    [CreadoEl]              DATETIME      NOT NULL,
    [ModificadoPor]         INT           NULL,
    [ModificadoEl]          DATETIME      NULL,
    [IsEliminado]           BIT           NULL,
    [EntregadoA]            VARCHAR (100) NULL,
    [IdLineaPresupuestoMes] INT           NULL,
    [IdSolicitudPedido]     INT           NULL,
    [ReingresSinRef]        BIT           NULL,
    CONSTRAINT [PK_IN_AL_Movimiento] PRIMARY KEY CLUSTERED ([IdMovimiento] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_IN_AL_Movimiento_IN_AL_TipoMovimiento] FOREIGN KEY ([IdTipoMovimiento]) REFERENCES [dbo].[IN_AL_TipoMovimiento] ([IdTipoMovimiento]),
    CONSTRAINT [FK_IN_AL_Movimiento_IN_Almacen] FOREIGN KEY ([IdAlmacen]) REFERENCES [dbo].[IN_Almacen] ([IdAlmacen]),
    CONSTRAINT [FK_IN_AL_Movimiento_MM_Pedido] FOREIGN KEY ([IdPedido]) REFERENCES [dbo].[MM_Pedido] ([IdPedido]),
    CONSTRAINT [FK_IN_AL_Movimiento_S_Usuario] FOREIGN KEY ([IdUsuarioAtendio]) REFERENCES [dbo].[S_Usuario] ([IdUsuario]),
    CONSTRAINT [FK_IN_AL_Movimiento_S_Usuario1] FOREIGN KEY ([IdUsuarioAutorizo]) REFERENCES [dbo].[S_Usuario] ([IdUsuario]),
    CONSTRAINT [FK_IN_AL_Movimiento_S_Usuario2] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[S_Usuario] ([IdUsuario]),
    CONSTRAINT [FK_IN_AL_Movimiento_S_Usuario3] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);


GO
CREATE TRIGGER [dbo].tr_IN_AL_Movimiento_upd ON [dbo].IN_AL_Movimiento
AFTER UPDATE
as

	if exists(
		select 1
		from inserted
		where IdUsuarioAutorizo > 0 and
		IsEliminado = 0
	)
	Begin

		select m.idMovimiento,md.IdMovimientoDetalle,m.IdAlmacen,md.IdMaterial,m.CreadoPor
		into #tmpMovs
		from inserted m
		inner join IN_AL_MovimientoDetalle md on md.IdMovimiento = m.IdMovimiento
		where ISNULL(m.IsEliminado,0) = 0

		declare  @pIdMovimientoDetalle int,
				@idAlmacen int,
				@idMaterial int,
				@creadoPor int

		select @pIdMovimientoDetalle = min(IdMovimientoDetalle)
		from #tmpMovs

		while @pIdMovimientoDetalle is not null
		begin
			
			select @idAlmacen =IdAlmacen,
				@idMaterial = IdMaterial,
				@creadoPor = CreadoPor
			from #tmpMovs
			where @pIdMovimientoDetalle = IdMovimientoDetalle

			exec p_IN_AL_CalcularExistencias @idAlmacen,@idMaterial,@pIdMovimientoDetalle,@creadoPor

			select @pIdMovimientoDetalle = min(IdMovimientoDetalle)
			from #tmpMovs
			where IdMovimientoDetalle > @pIdMovimientoDetalle

		end 
		

	End



