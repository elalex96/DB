/****** Object:  StoredProcedure [dbo].[Mobile_FiltroAprobaciones]    Script Date: 28/02/2019 05:42:39 p. m. ******/
CREATE PROC [dbo].[Mobile_FiltroAprobaciones] 
@IdContrato INT,
@IdUsuario INT,
----------------------------
@IdTipo INT =0,
@Number INT =NULL ,
@KeyWord NVARCHAR(300) = null,
@IdApp INT = 0

AS
BEGIN
DECLARE @EsPedido INT,@EsSolped INT;


IF @IdApp = 1
BEGIN
	IF	@Number IS NOT NULL
	BEGIN
	DECLARE @estatus INT,@tipoflijo INT, @nosecuencia INT, @EstatusNuevo INT ;
		
		IF EXISTS (SELECT 
		IdStatusAprobacionM,
		TipoFlujo,
		NoSecuencia
		FROM dbo.AM_Aprobacion WHERE IdPedido = @Number AND IdUsuario = @IdUsuario)
		BEGIN
			SELECT 
							@estatus = IdStatusAprobacionM,
							@tipoflijo= TipoFlujo,
							@nosecuencia= NoSecuencia
							FROM dbo.AM_Aprobacion WHERE IdPedido = @Number AND IdUsuario = @IdUsuario;
							IF	@tipoflijo = 2 OR @nosecuencia = 1
							BEGIN
							SELECT
					t.IdAprobacion AS 'Numero' ,
					t.ComentarioDocumento AS 'ComentarioDoc',
					t.ComentarioAprobacion AS 'ComentarioApr',
					CASE WHEN t.ComentarioAprobacionRechazo IS NULL THEN '' ELSE t.ComentarioAprobacionRechazo END AS 'ComentarioFinal',
					CASE WHEN CONVERT(nvarchar(10),t.FechaCreacion, 105) IS NULL THEN '-' ELSE CONVERT(nvarchar(10),t.FechaCreacion, 105) END AS 'FechaCreacion',
					CASE WHEN CONVERT(nvarchar(10),t.FechaModificacion, 105) IS NULL THEN '-' ELSE CONVERT(nvarchar(10),t.FechaModificacion, 105) END AS 'FechaModificacion',
					e.Status AS 'Estatus',
					t.IdTipoAprobacion AS 'idTipoAprobacion',
					t.IdStatusAprobacionM AS 'IdStatusAprobacionM',
					t.IdDocumento AS 'IdDocumento',
					t.IdTareaOrigen AS 'IdTareaOrigen',
					CASE WHEN t.idtipoaprobacion =9
						THEN
							'http://mobileprocura.adinco.mx/08Mobile/DetalleMobilePedido.aspx?doc=##IDDOC##&ver=##IDVER##' 
						WHEN  t.idtipoaprobacion =2
						THEN
							'http://mobileprocura.adinco.mx/08Mobile/DetalleMobile.aspx?doc=##IDDOC##&mono=##IDUS##'
						END
						AS 'URI',
					ta.TipoAprobacion AS 'TipoAprobacion',
					t.NoVersion AS 'NoVersion',
					t.IdPedido AS 'IdPedido',
					CASE WHEN t.IdTipoAprobacion = 2 THEN t.IdDocumento ELSE t.IdPedido END AS 'DisplayMember',
					0 AS 'Eliminado'
					FROM dbo.AM_Aprobacion AS t
					JOIN dbo.AM_StatusAprobacionM AS e
						ON e.IdStatusAprobacionM = t.IdStatusAprobacionM
					JOIN dbo.AM_TipoAprobacion AS ta 
						ON ta.idTipoAprobacion = t.IdTipoAprobacion
						WHERE 
						t.EsVisible= 1 AND t.IdStatusAprobacionM=1
						AND t.IdUsuario = @IdUsuario
						--AND t.IdContrato = @IdContrato
						AND t.IdTipoAprobacion IN (2,9)
						AND (cast(t.IdPedido as varchar(10))like '%' +cast(@Number as varchar(10))+ '%')
						ORDER BY YEAR(t.FechaCreacion) ASC
							END
							ELSE	
							BEGIN
								SET @EstatusNuevo=(SELECT IdStatusAprobacionM FROM dbo.AM_Aprobacion WHERE IdPedido = @Number AND NoSecuencia = (@nosecuencia-1))
								IF	@EstatusNuevo <>1
								BEGIN
								SELECT
									t.IdAprobacion AS 'Numero' ,
									t.ComentarioDocumento AS 'ComentarioDoc',
									t.ComentarioAprobacion AS 'ComentarioApr',
									CASE WHEN t.ComentarioAprobacionRechazo IS NULL THEN '' ELSE t.ComentarioAprobacionRechazo END AS 'ComentarioFinal',
									CASE WHEN CONVERT(nvarchar(10),t.FechaCreacion, 105) IS NULL THEN '-' ELSE CONVERT(nvarchar(10),t.FechaCreacion, 105) END AS 'FechaCreacion',
									CASE WHEN CONVERT(nvarchar(10),t.FechaModificacion, 105) IS NULL THEN '-' ELSE CONVERT(nvarchar(10),t.FechaModificacion, 105) END AS 'FechaModificacion',
									e.Status AS 'Estatus',
									t.IdTipoAprobacion AS 'idTipoAprobacion',
									t.IdStatusAprobacionM AS 'IdStatusAprobacionM',
									t.IdDocumento AS 'IdDocumento',
									t.IdTareaOrigen AS 'IdTareaOrigen',
									CASE WHEN t.idtipoaprobacion =9
										THEN
											'http://mobileprocura.adinco.mx/08Mobile/DetalleMobilePedido.aspx?doc=##IDDOC##&ver=##IDVER##' 
										WHEN  t.idtipoaprobacion =2
										THEN
											'http://mobileprocura.adinco.mx/08Mobile/DetalleMobile.aspx?doc=##IDDOC##&mono=##IDUS##'
										END
										AS 'URI',
									ta.TipoAprobacion AS 'TipoAprobacion',
									t.NoVersion AS 'NoVersion',
									t.IdPedido AS 'IdPedido',
									CASE WHEN t.IdTipoAprobacion = 2 THEN t.IdDocumento ELSE t.IdPedido END AS 'DisplayMember',
									0 AS 'Eliminado'
									FROM dbo.AM_Aprobacion AS t
									JOIN dbo.AM_StatusAprobacionM AS e
										ON e.IdStatusAprobacionM = t.IdStatusAprobacionM
									JOIN dbo.AM_TipoAprobacion AS ta 
										ON ta.idTipoAprobacion = t.IdTipoAprobacion
										WHERE 
										t.EsVisible= 1 AND t.IdStatusAprobacionM=1
										AND t.IdUsuario = @IdUsuario
										--AND t.IdContrato = @IdContrato
										AND t.IdTipoAprobacion IN (2,9)
										AND (cast(t.IdPedido as varchar(10))like '%' +cast(@Number as varchar(10))+ '%')
										ORDER BY YEAR(t.FechaCreacion) ASC
                                END
                            END

        END
		ELSE
        BEGIN
				SELECT 
							@estatus = IdStatusAprobacionM,
							@tipoflijo= TipoFlujo,
							@nosecuencia= NoSecuencia
							FROM dbo.AM_Aprobacion WHERE IdDocumento = @Number AND IdUsuario = @IdUsuario;
							IF	@tipoflijo = 2 OR @nosecuencia = 1
							BEGIN
							SELECT
								t.IdAprobacion AS 'Numero' ,
								t.ComentarioDocumento AS 'ComentarioDoc',
								t.ComentarioAprobacion AS 'ComentarioApr',
								CASE WHEN t.ComentarioAprobacionRechazo IS NULL THEN '' ELSE t.ComentarioAprobacionRechazo END AS 'ComentarioFinal',
								CASE WHEN CONVERT(nvarchar(10),t.FechaCreacion, 105) IS NULL THEN '-' ELSE CONVERT(nvarchar(10),t.FechaCreacion, 105) END AS 'FechaCreacion',
								CASE WHEN CONVERT(nvarchar(10),t.FechaModificacion, 105) IS NULL THEN '-' ELSE CONVERT(nvarchar(10),t.FechaModificacion, 105) END AS 'FechaModificacion',
								e.Status AS 'Estatus',
								t.IdTipoAprobacion AS 'idTipoAprobacion',
								t.IdStatusAprobacionM AS 'IdStatusAprobacionM',
								t.IdDocumento AS 'IdDocumento',
								t.IdTareaOrigen AS 'IdTareaOrigen',
								CASE WHEN t.idtipoaprobacion =9
									THEN
										'http://mobileprocura.adinco.mx/08Mobile/DetalleMobilePedido.aspx?doc=##IDDOC##&ver=##IDVER##' 
									WHEN  t.idtipoaprobacion =2
									THEN
										'http://mobileprocura.adinco.mx/08Mobile/DetalleMobile.aspx?doc=##IDDOC##&mono=##IDUS##'
									END
									AS 'URI',
								ta.TipoAprobacion AS 'TipoAprobacion',
								t.NoVersion AS 'NoVersion',
								t.IdPedido AS 'IdPedido',
								CASE WHEN t.IdTipoAprobacion = 2 THEN t.IdDocumento ELSE t.IdPedido END AS 'DisplayMember',
								0 AS 'Eliminado'
								FROM dbo.AM_Aprobacion AS t
								JOIN dbo.AM_StatusAprobacionM AS e
									ON e.IdStatusAprobacionM = t.IdStatusAprobacionM
								JOIN dbo.AM_TipoAprobacion AS ta 
									ON ta.idTipoAprobacion = t.IdTipoAprobacion
									WHERE 
									t.EsVisible= 1 AND t.IdStatusAprobacionM=1
									AND t.IdUsuario = @IdUsuario
									--AND t.IdContrato = @IdContrato
									AND t.IdTipoAprobacion IN (2,9)
									AND (cast(t.IdDocumento as varchar(10))like '%' +cast(@Number as varchar(10))+ '%')
									ORDER BY YEAR(t.FechaCreacion) ASC
							END
							ELSE	
							BEGIN
								SET @EstatusNuevo=(SELECT IdStatusAprobacionM FROM dbo.AM_Aprobacion WHERE IdDocumento = @Number AND NoSecuencia = (@nosecuencia-1))
								IF	@EstatusNuevo <>1
								BEGIN
								SELECT
									t.IdAprobacion AS 'Numero' ,
									t.ComentarioDocumento AS 'ComentarioDoc',
									t.ComentarioAprobacion AS 'ComentarioApr',
									CASE WHEN t.ComentarioAprobacionRechazo IS NULL THEN '' ELSE t.ComentarioAprobacionRechazo END AS 'ComentarioFinal',
									CASE WHEN CONVERT(nvarchar(10),t.FechaCreacion, 105) IS NULL THEN '-' ELSE CONVERT(nvarchar(10),t.FechaCreacion, 105) END AS 'FechaCreacion',
									CASE WHEN CONVERT(nvarchar(10),t.FechaModificacion, 105) IS NULL THEN '-' ELSE CONVERT(nvarchar(10),t.FechaModificacion, 105) END AS 'FechaModificacion',
									e.Status AS 'Estatus',
									t.IdTipoAprobacion AS 'idTipoAprobacion',
									t.IdStatusAprobacionM AS 'IdStatusAprobacionM',
									t.IdDocumento AS 'IdDocumento',
									t.IdTareaOrigen AS 'IdTareaOrigen',
									CASE WHEN t.idtipoaprobacion =9
										THEN
											'http://mobileprocura.adinco.mx/08Mobile/DetalleMobilePedido.aspx?doc=##IDDOC##&ver=##IDVER##' 
										WHEN  t.idtipoaprobacion =2
										THEN
											'http://mobileprocura.adinco.mx/08Mobile/DetalleMobile.aspx?doc=##IDDOC##&mono=##IDUS##'
										END
										AS 'URI',
									ta.TipoAprobacion AS 'TipoAprobacion',
									t.NoVersion AS 'NoVersion',
									t.IdPedido AS 'IdPedido',
									CASE WHEN t.IdTipoAprobacion = 2 THEN t.IdDocumento ELSE t.IdPedido END AS 'DisplayMember',
									0 AS 'Eliminado'
									FROM dbo.AM_Aprobacion AS t
									JOIN dbo.AM_StatusAprobacionM AS e
										ON e.IdStatusAprobacionM = t.IdStatusAprobacionM
									JOIN dbo.AM_TipoAprobacion AS ta 
										ON ta.idTipoAprobacion = t.IdTipoAprobacion
										WHERE 
										t.EsVisible= 1 AND t.IdStatusAprobacionM=1
										AND t.IdUsuario = @IdUsuario
										--AND t.IdContrato = @IdContrato
										AND t.IdTipoAprobacion IN (2,9)
										AND (cast(t.IdDocumento as varchar(10))  Like '%' +cast(@Number as varchar(10))+ '%' )
										ORDER BY YEAR(t.FechaCreacion) ASC
                                END
                            END


        END
        

		----------------------------------------------------------------------------
		
    END
	IF	@KeyWord IS NOT NULL
	BEGIN
			SELECT DISTINCT
		t.IdAprobacion AS 'Numero' ,
		t.ComentarioDocumento AS 'ComentarioDoc',
		t.ComentarioAprobacion AS 'ComentarioApr',
		CASE WHEN t.ComentarioAprobacionRechazo IS NULL THEN '' ELSE t.ComentarioAprobacionRechazo END AS 'ComentarioFinal',
		CASE WHEN CONVERT(nvarchar(10),t.FechaCreacion, 105) IS NULL THEN '-' ELSE CONVERT(nvarchar(10),t.FechaCreacion, 105) END AS 'FechaCreacion',
		CASE WHEN CONVERT(nvarchar(10),t.FechaModificacion, 105) IS NULL THEN '-' ELSE CONVERT(nvarchar(10),t.FechaModificacion, 105) END AS 'FechaModificacion',
		e.Status AS 'Estatus',
		t.IdTipoAprobacion AS 'idTipoAprobacion',
		t.IdStatusAprobacionM AS 'IdStatusAprobacionM',
		t.IdDocumento AS 'IdDocumento',
		t.IdTareaOrigen AS 'IdTareaOrigen',
		CASE WHEN t.idtipoaprobacion =9
			THEN
				'http://mobileprocura.adinco.mx/08Mobile/DetalleMobilePedido.aspx?doc=##IDDOC##&ver=##IDVER##' 
			WHEN  t.idtipoaprobacion =2
			THEN
				'http://mobileprocura.adinco.mx/08Mobile/DetalleMobile.aspx?doc=##IDDOC##&mono=##IDUS##'
			END
			AS 'URI',
		ta.TipoAprobacion AS 'TipoAprobacion',
		t.NoVersion AS 'NoVersion',
		t.IdPedido AS 'IdPedido',
		CASE WHEN t.IdTipoAprobacion = 2 THEN t.IdDocumento ELSE t.IdPedido END AS 'DisplayMember',
		0 AS 'Eliminado'
		FROM dbo.AM_Aprobacion AS t
		JOIN dbo.AM_StatusAprobacionM AS e
			ON e.IdStatusAprobacionM = t.IdStatusAprobacionM
		JOIN dbo.AM_TipoAprobacion AS ta 
			ON ta.idTipoAprobacion = t.IdTipoAprobacion
			WHERE 
			t.EsVisible= 1 AND t.IdStatusAprobacionM=1
			AND t.IdUsuario = @IdUsuario
			--AND t.IdContrato = @IdContrato
			AND t.IdTipoAprobacion IN (2,9)
			AND	(t.ComentarioAprobacion LIKE '%'+@KeyWord+'%' OR t.ComentarioDocumento LIKE '%'+@KeyWord+'%')
				--AND	(AP.ComentarioAprobacion LIKE '%'+@KeyWord+'%' OR AP.ComentarioDocumento LIKE '%'+@KeyWord+'%')
			
    END
END
END