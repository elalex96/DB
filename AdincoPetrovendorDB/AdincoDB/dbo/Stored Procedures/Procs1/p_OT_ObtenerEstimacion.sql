CREATE Proc p_OT_ObtenerEstimacion
@pIdOTSolicitud int,
@pIdOTEstimacion int,
@pFechaInicioEstimacion datetime	=	null,
@pFechaFinEstimacion datetime	=	null
AS

	DECLARE @consecutivo INT,
			@fechaIniCorte DATETIME
	
	CREATE TABLE #Temp (IdOTSolicitud INT,
						IdSCMaterial INT,
						COncepto VARCHAR(50),
						Descripcion VARCHAR(1000),
						Unidad VARCHAR(MAX),
						Cantidad FLOAT,
						PrecioUnitario MONEY,
						Importe MONEY,
						FechaInicioSubcontratista DATETIME,
						FechaFinSubcontratista DATETIME,
						IdOTSolicitudMaterial INT);


	IF  (
		ISNULL(@pIdOTEstimacion,0) > 0
		)
	BEGIN

		SELECT *
		FROM 
			vwOTEstimacion
		WHERE 
			IdOTEstimacion	=	@pIdOTEstimacion

	END
	ELSE
	BEGIN 

		SELECT 
			@consecutivo = ISNULL(MAX(Consecutivo),0) + 1
		FROM 
				OT_Estimacion
		WHERE 
				IdOTSolicitud	=	@pIdOTSolicitud


		SELECT 
			@fechaIniCorte = dateadd(dd,1,max(FechaCorteFin))
		FROM 
			OT_Estimacion
		WHERE 
			IdOTSolicitud = @pIdOTSolicitud 

		IF(@fechaIniCorte IS NULL)
		BEGIN

			SELECT 
				@fechaIniCorte = MIN(Fecha)
			FROM 
				[dbo].[OT_SolicitudProgramaCaptura] spc
			JOIN 
				[dbo].OT_SolicitudMaterial	sp 
				ON	spc.IdOTSolicitudMaterial	=	sp.IdOTSolicitudMaterial
			WHERE 
				sp.IdOTSolicitud	=	@pIdOTSolicitud

		END

		
		INSERT INTO #TEMP(IdOTSolicitud,
						IdSCMaterial,
						COncepto,
						Descripcion,
						Unidad,
						Cantidad,
						PrecioUnitario,
						Importe,
						FechaInicioSubcontratista,
						FechaFinSubcontratista,
						IdOTSolicitudMaterial)
		SELECT 
						om.IdOTSolicitud,
						scm.IdSCMaterial,
						scm.COncepto,
						scm.Descripcion,
						Unidad = Unidad,
						Cantidad = sum(spc.Captura),
						PrecioUnitario = scm.PrecioUnitario,
						Importe = isnull(sum(spc.Captura),0) * isnull(scm.PrecioUnitario,0),
						FechaInicioSubcontratista = Min(spc.Fecha),
						FechaFinSubcontratista = Max(spc.Fecha)	,
						om.IdOTSolicitudMaterial
					FROM 
						[dbo].[OT_SolicitudProgramaCaptura] spc
					JOIN
						OT_SolicitudMaterial om 
						ON  spc.IdOTSolicitudMaterial = om.IdOTSolicitudMaterial
					JOIN 
						SC_Materiales scm 
						ON om.IdSCMaterial =  scm.IdSCMaterial
					JOIN 
						Petrovendor.dbo.[PV_MM_MaterialUnidad] u 
						ON scm.IdUnidad = u.IdUnidad 
					WHERE 
						om.IdOTSolicitud = @pIdOTSolicitud
						AND	VoBoContratista = 1 AND
					(
						CONVERT(VARCHAR,spc.Fecha,112) BETWEEN	CONVERT(VARCHAR,@pFechaInicioEstimacion,112) AND 
																CONVERT(VARCHAR,@pFechaFinEstimacion,112)
						OR 
						(
								@pFechaInicioEstimacion IS NULL 
							AND 
								@pFechaFinEstimacion IS NULL
						)

					)
					GROUP BY 
							om.IdOTSolicitud,
							scm.IdSCMaterial,
							scm.COncepto,
							scm.Descripcion,
							Unidad,
							scm.PrecioUnitario,
							om.IdOTSolicitudMaterial



		SELECT 
			ot.IdOTSolicitud,
			IdOTEstimacion = 0,
			FolioEstimacion = ot.Folio +'-E' + cast(@consecutivo as varchar),
			Consecutivo = 0,
			FolioOT = ot.Folio,
			FolioSC = sc.NumeroSubContrato	,
			FechaIniCorte = @fechaIniCorte,
			FechaFinCorte = @fechaIniCorte,
			Instalacion = max(isnull(ins.NombreInstalacion,'INDEFINIDA')),
			Actividad = isnull(ACT.NombreActividad,'INDEFINIDA'),
			Presupuesto = pre.Nombre,
			Subcontratista = subc.RazonSocial,
			AreaContractual=cont.NombreContratista,
			AceptaOperador = cont.Representante,
			AceptaSubcontratista = subc.RepresentanteLegal,
			tmp.IdSCMaterial,
			tmp.COncepto,
			tmp.Descripcion,
			tmp.Unidad,
			Cantidad = cast(tmp.Cantidad as float),
			tmp.PrecioUnitario,
			tmp.Importe,
			tmp.IdOTSolicitudMaterial,
			Moneda = isnull(mon.TipoMonedaCorto,''),
			IdMoneda = ot.IdMOneda			
			FROM
				OT_Solicitud ot
			JOIN 
				#Temp tmp
				ON ot.IdOTSolicitud = tmp.IdOTSolicitud 
			JOIN 
				SC_Subcontrato sc 
				ON  ot.IdSubContrato =  sc.IdSubcontrato
			JOIN 
				PV_Subcontratista subc 
				ON sc.IdSubContratista = subc.IdSubcontratista 
			JOIN 
				OT_LineaPresupuesto OTlp 
				ON ot.IdOTSolicitud =  OTlp.IdOTSolicitud 
			JOIN 
				CO_LineaPresupuestoMes lp 
				ON  OTlp.IdLineaPresupuestoMes = lp.[IdLineaPresupuestoMes] 
			JOIN 
				CO_Presupuesto pre 
				ON lp.IdPresupuesto	= pre.IdPresupuesto 
			JOIN 
				[dbo].[CO_Contratista] cont 
				ON sc.IdContratista = cont.IdContratista 
			
			LEFT JOIN 
				Petrovendor.dbo.MM_Pedido ped 
				ON sc.IdPedido =  ped.IdPedido
			LEFT JOIN 
				Petrovendor.dbo.PV_TipoMoneda mon 
				ON ot.IdMOneda = mon.idMoneda 
			LEFT JOIN 
				OT_SolicitudInstalacion OTins 
				ON  ot.IdOTSolicitud	=	OTins.idOTSolicitud
			LEFT JOIN 
				CO_Instalacion ins 
				ON  OTins.IdInstalacion =	ins.IdInstalacion
			LEFT JOIN 
				CO_ActividadCIEP act 
				ON ins.IdActividad = act.IdActividad 
			WHERE		
						ot.IdOTSolicitud	=	@pIdOTSolicitud
			GROUP BY	
						ot.IdOTSolicitud,			
						ot.Folio ,			
						sc.NumeroSubContrato	,	
						ACT.NombreActividad,
						pre.Nombre,
						subc.RazonSocial,
						cont.NombreContratista,
						cont.Representante,
						subc.RepresentanteLegal,
						tmp.IdSCMaterial,
						tmp.COncepto,
						tmp.Descripcion,
						tmp.Unidad,
						tmp.Cantidad,
						tmp.PrecioUnitario,
						tmp.Importe,
						tmp.IdOTSolicitudMaterial,
						mon.TipoMonedaCorto,
						ot.IdMOneda			

	END