
-- =============================================  
-- Author:   Daniel AC  
-- Create date: 15/10/2020  
-- Description: Consultar avance del porcentaje de un Entregable Instancia 
-- ============================================= 
CREATE PROCEDURE [dbo].[SP_EN_ConsultarAvanceEntregableSeguimiento]
    @EntregableInstanciaId INT,
    @UsuarioId INT,
    @ContratoId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @PorcentajeAprobacion	FLOAT,
    @PorcentajeElaboracion			FLOAT,
    @PorcentajeRevision				FLOAT,
    @EnAprobacion					INT = 10002, --> EN APROBACIÓN
    @EnRevision						INT = 10001, --> EN REVISION
    @EnElaboracion					INT = 10000, --> EN ELABORACIÓN
    @AprobadoInternamente			INT = 10003, --> APROBADO INTERNAMENTE
    @PorcentajePorEstado			FLOAT = CAST(100 AS FLOAT) / CAST(3 AS FLOAT), --> EL 100% DEL AVANCE ENTRE LOS 3 ESTADOS DEL ENTREGABLE
    @PorcentajeSinInicia			VARCHAR(MAX),
	@EsAdministrador				bit

   
    create table #SeguimientoPorUsuario 
    (
        EstadoId INT,
        UsuarioId INT,
        Porcentaje FLOAT,
        FechaModificacionUsuario DATETIME,
        ComentarioUsuario NVARCHAR(MAX),
        Avance VARCHAR(MAX)
    );

    --VALIDAR SI LA INSTANCIA SOLICITADA EXISTE SI NO CREARLA 
	 EXEC dbo.SP_EN_CrearSeguimientoAvanceEntregable @EntregableInstanciaId = @EntregableInstanciaId, -- int
                                                @UsuarioId = @UsuarioId,             -- int
                                                @ContratoId = @ContratoId            -- int

	/*OBTENER LA INFORMACIÓN DE LOS PORCENTAJES DE LOS USUARIOS DEL FLUJO*/
    INSERT INTO #SeguimientoPorUsuario
    (
        EstadoId,
        UsuarioId,
        Porcentaje,
        FechaModificacionUsuario,
        ComentarioUsuario,
        Avance
    )
    SELECT ESU.IdEstado,
           ESU.UsuarioId,
           ESU.Porcentaje,
           ESU.FechaModificacionUsuario,
           ESU.ComentarioUsuario,
           ESU.NombreAvance
    FROM EN_AvanceEntregableSeguimientoUsuario ESU
    WHERE ESU.EntregableInstanciaId = @EntregableInstanciaId
          AND ESU.Activo = 1;


	/*OBTENER SUMATORIAS DE LOS PORCENTAJES POR ESTADO*/
    SELECT @PorcentajeElaboracion = CASE
                                        WHEN SUM(Porcentaje) > @PorcentajePorEstado THEN
                                            @PorcentajePorEstado
                                        ELSE
                                            SUM(Porcentaje)
                                    END
    FROM #SeguimientoPorUsuario
    WHERE EstadoId = @EnElaboracion;

    SELECT @PorcentajeRevision = CASE
                                     WHEN SUM(Porcentaje) > @PorcentajePorEstado THEN
                                         @PorcentajePorEstado
                                     ELSE
                                         SUM(Porcentaje)
                                 END
    FROM #SeguimientoPorUsuario
    WHERE EstadoId = @EnRevision;

    SELECT @PorcentajeAprobacion = CASE
                                       WHEN SUM(Porcentaje) > @PorcentajePorEstado THEN
                                           @PorcentajePorEstado
                                       ELSE
                                           SUM(Porcentaje)
                                   END
    FROM #SeguimientoPorUsuario
    WHERE EstadoId = @EnAprobacion;

    --PRIMER TABLA DETALLE DE PORCENTAJES GENERALES POR ESTADO
    SELECT S.Id,
           PorcentajeEntregable = CASE
                                      WHEN S.Porcentaje > 100 THEN
                                          100
                                      ELSE
                                          S.Porcentaje
                                  END,
           PorcentajeAprobacion = ISNULL(@PorcentajeAprobacion, 0),
           PorcentajeElaboracion = ISNULL(@PorcentajeElaboracion, 0),
           PorcentajeRevision = ISNULL(@PorcentajeRevision, 0),
           AvanceAprobacion = CASE
                                  WHEN @PorcentajePorEstado = ISNULL(@PorcentajeAprobacion, 0) THEN
                                      'Completado'
                                  WHEN @PorcentajeAprobacion = 0 THEN
                                      'No iniciado'
                                  ELSE
                                      'En proceso'
                              END,
           AvanceElaboracion = CASE
                                   WHEN @PorcentajePorEstado = ISNULL(@PorcentajeElaboracion, 0) THEN
                                       'Completado'
                                   WHEN @PorcentajeElaboracion = 0 THEN
                                       'No iniciado'
                                   ELSE
                                       'En proceso'
                               END,
           AvanceRevision = CASE
                                WHEN @PorcentajePorEstado = ISNULL(@PorcentajeRevision, 0) THEN
                                    'Completado'
                                WHEN @PorcentajeRevision = 0 THEN
                                    'No iniciado'
                                ELSE
                                    'En proceso'
                            END
    FROM dbo.EN_AvanceEntregableSeguimiento S
    WHERE S.EntregableInstanciaId = @EntregableInstanciaId
          AND S.Activo = 1;

	if exists(
	select		* 
	from		Ap_PerfilUsuario	pu
	inner join	AP_Perfil			p
	on			pu.PerfilID			=	p.IdPerfil
	and			pu.UsuarioID		=	@UsuarioId
	and			p.IdContrato		=	@ContratoId
	inner join	AP_Rol				r
	on			p.IdRol				=	r.IdRol
	where		rol					like '%admin%'
	and			pu.UsuarioID		=	@UsuarioId
	and			p.IdContrato		=	@ContratoId
	)
	begin
		select	@EsAdministrador = 1
	end
	else
	begin
		select	@EsAdministrador = 0
	end

    --SEGUNDA TABLA PORCENTAJE POR ESTADO Y POR USUARIO	
    SELECT UsuarioId				=	SU.UsuarioId,
           Usuario					=	U.Nombre,
           Porcentaje				=	SU.Porcentaje,
           EstadoId					=	SU.EstadoId,
           Estado					=	E.NombreEstado,
           EntregableInstanciaId	=	@EntregableInstanciaId,
			ClaveEstado				=	CASE
										 WHEN E.EstadoID = @EnElaboracion THEN
											 'ELABORACION'
										 WHEN E.EstadoID = @EnRevision THEN
											 'REVISION'
										 WHEN E.EstadoID = @EnAprobacion THEN
											 'APROBACION'
										 ELSE
											 'NO-IDENTIFICADO'
									 END,
           PermitirEdicion			= CASE
										 WHEN SU.UsuarioId = @UsuarioId or @EsAdministrador = 1 THEN
											 'SI'
										 ELSE
											 'NO'
									 END,
           Avance = ISNULL(SU.Avance, 'No iniciado'),
           FechaModificacionUsuario = ISNULL(FORMAT(SU.FechaModificacionUsuario, 'dd/MM/yyyy hh:mm tt'), ''),
           Comentario = ISNULL(SU.ComentarioUsuario, '')
	--into	#tmp
    FROM #SeguimientoPorUsuario SU
        JOIN dbo.AP_Usuario U
            ON SU.UsuarioId = U.UsuarioID
        JOIN dbo.EN_Estado E
            ON SU.EstadoId = E.EstadoID;
	

    --TABLA 3 HISTORIAL DEL AVANCE DEL ENTREGABLE 
    SELECT Estado = ISNULL(E.NombreEstado, ''),
           Detalle = ISNULL(H.Detalle, ''),
           Comentario = ISNULL(H.Comentario, ''),
           Fecha = ISNULL(FORMAT(H.CreadoEl, 'dd/MM/yyyy hh:mm tt'), ''),
           Usuario = U.Nombre,
           ColorLabel = CASE
                            WHEN E.EstadoID = @EnElaboracion THEN
                                'tl-label bs-label label-info'
                            WHEN E.EstadoID = @EnRevision THEN
                                'tl-label bs-label label-warning'
                            WHEN E.EstadoID = @EnAprobacion THEN
                                'tl-label bs-label label-success'
                            ELSE
                                'tl-label bs-label bg-default'
                        END
    FROM dbo.EN_AvanceEntregableHistorial H
        LEFT JOIN AP_Usuario U
            ON H.CreadoPor = U.UsuarioID
        LEFT JOIN dbo.EN_Estado E
            ON H.IdEstado = E.EstadoID
    WHERE H.EntregableInstanciaId = @EntregableInstanciaId
    ORDER BY H.CreadoEl DESC;
END;