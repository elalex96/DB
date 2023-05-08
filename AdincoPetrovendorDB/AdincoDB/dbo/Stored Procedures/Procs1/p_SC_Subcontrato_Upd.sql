---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE proc [dbo].[p_SC_Subcontrato_Upd]
(
	@pIdSubContrato		int,
	@pIdSubContratista	int,
	@pNumeroSubContrato	varchar(20),
	@pObjeto			varchar(300),
	@pIdCentroCosto		int,
	@pIdContratista		int,
	@pIdMoneda			int,
	@pPrefijoOT			varchar(13),
	@pFechaInicio		DateTime=null,
	@pFechaFin			DateTime=null,
	@pError				varchar(250)='' out
)
as
begin
/*DROP TABLE #OTSolicitudesSubcontrato
DROP TABLE #OTEstNoPuedeModificar*/
	CREATE TABLE #OTSolicitudesSubcontrato( Id INT IDENTITY(1,1),  IdOTSolicitud INT,IdSubContrato INT, IdOTEstimacion INT,IdSolicitudPedido INT, IdPedido INT);
	CREATE TABLE #OTEstNoPuedeModificar( Id INT IDENTITY(1,1), IdOTEstimacion INT);
	DECLARE @MonedaIdAntes INT = 0;

	if(substring(@pPrefijoOT,1,3)<>'OT-')
	begin
		select @pPrefijoOT = 'OT-'+@pPrefijoOT
	end

	if	(	(
					select	count(*	)
					from	SC_SubContrato 
					where	NumeroSubContrato	=	@pNumeroSubContrato 
					and		IdSubContrato	<>	@pIdSubContrato
					and		IdContratista		=	@pIdContratista
					and		IsActivo			=	1
				)>1)
	begin
		select	@pError = '[ALERTA] Hay mas de un registro con ese Numero de Subcontrato'
		return
	end

	if exists (
				
				select	1
				from	SC_SubContrato 
				where	NumeroSubContrato	=	@pNumeroSubContrato 
				and		IdSubContrato		<>	@pIdSubContrato
				and		IdContratista		=	@pIdContratista
				and		IsActivo				=	1
				
	)
	begin
		set @pError = '[ALERTA] Este número de Sub Contrato esta siendo utilizado en otro contrato activo, es necesario modificar'
		return
	end

	SELECT @MonedaIdAntes = IdMoneda FROM SC_SubContrato	WHERE IdSubContrato	=	@pIdSubContrato;

	update	SC_SubContrato
	set		IdSubContratista	=	@pIdSubContratista,
			NumeroSubContrato	=	@pNumeroSubContrato,
			Objeto				=	@pObjeto,
			IdCentroCosto		=	@pIdCentroCosto,
			IdMoneda			=	@pIdMoneda,
			PrefijoOT			=	@pPrefijoOT,
			FechaInicio			=	@pFechaInicio,
			FechaFin			=	@pFechaFin
	where	IdSubContrato		=	@pIdSubContrato
	
		/*NUEVA IMPLEMENTACION DE ISSUE 1482 --AL ACTUALIZAR LA MONEDA SE ACTUALIZARÁN:
		1 - (ACTUALIZACION OT_Solicitud) Buscar las solicitudes por la columna IdSubContrato de la table OT_Solicitud  -> DONDE ESTE ACTIVO Y TENGA ESTATUS <> A 12
		2 - Buscar las estimaciones TABLA: ADINCO OT_Estimacion llego a partir de  IdOTSolicitud
		3 - VALIDACION DE PETROVENDOR PARA VER SI SE PUEDE MODIFICAR EN PETROVENDOR
		4 - (ACTUALIZACION MM_PeticionOfertaDetalle) petrovendor..MM_PeticionOfertaDetalle - > llego apartir de la tabla: petrovendor..MM_PeticionOferta  -> LLEGO A PARTIR DE COLUMNA IdSolicitudPedido DE TABLA: ADINCO OT_Estimacion (2) 
		5 - (ACTUALIZACION MM_PedidoDetalle) petrovendor..MM_PedidoDetalle - > llego a partir de la tabla: petrovendor..MM_Pedido -> LLEGO APARTIR DE IdPedido DE ADINCO..OT_Estimacion (1)*/

	 --ACTUALIZACION DE MONEDA:

	IF(@MonedaIdAntes <> @pIdMoneda)
	BEGIN

		INSERT INTO #OTSolicitudesSubcontrato (IdOTSolicitud ,IdSubContrato, IdOTEstimacion,IdSolicitudPedido, IdPedido)
		SELECT S.IdOTSolicitud,IdSubContrato,IdOTEstimacion,IdSolicitudPedido,IdPedido
		FROM 
			OT_Solicitud	S
		JOIN
			OT_Estimacion	E
			ON	S.IdOTSolicitud	=	E.IdOTSolicitud
		WHERE	
			S.IdSubContrato	=	@pIdSubContrato 
		AND S.IsActivo	=	1
		AND	S.IdOTEstatus <> 12; --SE MENCIONO QUE EL ESTATUS ES 12 (ESTATICO)
 
		UPDATE OT_Solicitud	
			SET IdMoneda = @pIdMoneda
		WHERE	
			IdSubContrato	=	@pIdSubContrato 
		AND IsActivo	=	1
		AND	IdOTEstatus <> 12; --SE MENCIONO QUE EL ESTATUS ES 12 (ESTATICO)

		--NO SE PUEDE MODICAR, YA QUE YA CONTIENE CARTA DE CN																								
		INSERT INTO #OTEstNoPuedeModificar (IdOTEstimacion)
		SELECT OTS.IdOTEstimacion
		FROM
			#OTSolicitudesSubcontrato	OTS
		JOIN
			petrovendor..MM_Pedido PP
			ON	OTS.IdPedido	=	PP.IdPedido
		JOIN	petrovendor..MM_AceptacionPedido		AP 
			ON	PP.IdPedido	=	AP.IdPedido
		JOIN	petrovendor..[MM_AceptacionCartaPCN]	CN 
			ON	AP.IdAceptacionPedido	=	CN.IdAceptacionPedido
		AND	cn.IdEstatus	=	2
		WHERE	AP.Activo	=	1 
			AND
			ISNULL(cn.IdEliminado,0) = 0
		GROUP BY	OTS.IdOTEstimacion
		ORDER BY OTS.IdOTEstimacion ASC

		--SE ELIMINAN DE LA TABLA TEMPORAL LAS OT ESTIMACION QUE YA TIENEN CARTAS CN
		DELETE OTS
		FROM 
			#OTSolicitudesSubcontrato	OTS
		JOIN
			#OTEstNoPuedeModificar	OTNO
			ON	OTS.IdOTEstimacion	=	OTNO.IdOTEstimacion;

		IF ((SELECT COUNT(1) FROM #OTSolicitudesSubcontrato) > 0)
		BEGIN
			UPDATE POD
				SET  POD.IdMoneda	=	@pIdMoneda
			FROM
				#OTSolicitudesSubcontrato OTS
			JOIN
				petrovendor..MM_PeticionOferta	PO
				ON	OTS.IdSolicitudPedido	=	PO.IdSolicitudPedido
			JOIN
				petrovendor..MM_PeticionOfertaDetalle	POD
				ON	PO.IdPeticionOferta	=	POD.IdPeticionOferta;
		
			UPDATE P
				SET P.IdMoneda	=	@pIdMoneda
			FROM 
				#OTSolicitudesSubcontrato OTS
			JOIN
				petrovendor..MM_Pedido P
				ON	OTS.IdPedido	=	P.IdPedido;


			UPDATE PDP
				SET PDP.IdMoneda	=	@pIdMoneda
			FROM 
				#OTSolicitudesSubcontrato OTS
			JOIN
				petrovendor..MM_PedidoDetalle PDP
				ON	OTS.IdPedido	=	PDP.IdPedido
				
			set @pError = '[ACTUALIZACIÓN] SE ACTUALIZO LA MONEDA DE PEDIDOS DE PROCURA SIN CARTA APROBADA'
			return
		END


	 END
end




