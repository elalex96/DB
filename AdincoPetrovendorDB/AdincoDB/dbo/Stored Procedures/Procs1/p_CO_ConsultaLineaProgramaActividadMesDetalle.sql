
CREATE PROC [dbo].[p_CO_ConsultaLineaProgramaActividadMesDetalle] 
--p_CO_ConsultaLineaProgramaActividadMesDetalle 3,'2018-08-01',10008
@pidContrato          INT, 
@pAnioMes             DATETIME, 
@pIdProgramaActividad INT,
@pIdPeriodo INT
--
AS
BEGIN
			SELECT DISTINCT   
            pam.IdLineaProgramaActividadMes,   
            pam.IdProgramaActividad,   
            pam.IdActividadPetrolera,   
            pam.IdSubactividadPetrolera,   
            pam.IdTareaPetrolera,   
            pam.IdSubTareaPetrolera,   
            Programa = pa.NombrePrograma,   
            DescripcionActividadPetrolera = UPPER(ap.DescripcionActividadPetrolera),   
            SubactividadPetrolera = UPPER(sap.SubactividadPetrolera),   
            TareaPetrolera = UPPER(tp.TareaPetrolera),   
            s.IdServicio,   
            SubTareaPetrolera = UPPER(isnull(s.NombreServicio, '')),   
            pam.NumeroAnio,   
            pam.NumeroMes,   
            pam.Actividades,   
            pam.Fecha,   
            pamD.Id,   
            pamD.CantidadEjecutar,   
            UTUnidad = ISNULL(pamD.UTUnidad, 0),   
            FechaInicio = CONVERT(VARCHAR, pamD.FechaInicio, 103),   
            FechaFin = CONVERT(VARCHAR, pamD.FechaFin, 103),   
            pamD.Comentarios,   
            pamD.CreadoEl,   
            pamD.CreadoPor,   
            UnidadServicio = uniS.Unidad,   
            AcreditaUT = case when pamD.UTUnidad > 0 then 'SI' else 'NO ' END,   
            UTSTotales = isnull(pamD.CantidadEjecutar, 0) * isnull(pamD.UTUnidad, 0)  
     INTO #tmpPrincipal  
     FROM CO_PeriodoContrato pc  
          LEFT JOIN CO_ProgramaActividad pa ON pa.IdPeriodoContrato = pc.IdPeriodo  
          LEFT JOIN CO_Presupuesto pre ON pre.IdProgramaActividad = pa.IdProgramaActividad  
          LEFT JOIN [dbo].[CO_AnioContractual] anioC ON anioC.IdAnioContractual = pre.IdAnioContractual  
          LEFT JOIN [CO_LineaProgramaActividadMes] pam ON pam.IdProgramaActividad = pa.IdProgramaActividad  
          LEFT JOIN CO_ActividadPetroleraCNH ap ON ap.IdActividadPetrolera = pam.IdActividadPetrolera  
          LEFT JOIN CO_SubactividadPetrolera sap ON sap.IdSubactividadPetrolera = pam.IdSubactividadPetrolera  
          LEFT JOIN dbo.CO_TareaPetrolera tp ON tp.IdTareaPetrolera = pam.IdTareaPetrolera  
          LEFT JOIN [dbo].CO_Servicio s ON s.IdServicio = pam.IdSubTareaPetrolera  
          LEFT JOIN CO_Unidad uniS ON uniS.IdUnidad = s.IdUnidad  
          LEFT JOIN [CO_LineaProgramaActividadMesDetalle] pamD ON pamD.IdLineaProgramaActividadMes = pam.IdLineaProgramaActividadMes  
     WHERE pc.IdContrato = @pidContrato --and      
           AND pa.IdProgramaActividad = @pIdProgramaActividad;


     SELECT		
     --t1.IdLineaProgramaActividadMes,
     pa.IdProgramaActividad, 
     CO_ActividadPetroleraCNH.IdActividadPetrolera, 
     CO_SubactividadPetrolera.IdSubactividadPetrolera, 
     CO_TareaPetrolera.IdTareaPetrolera, 
     CO_ActividadPetroleraCNH.id_Actividad, 
     CO_Servicio.IdServicio, 
     --PlanAct = t1.Actividades, 
	 --PlanAct = SUM(isnull(lpamD.CantidadEjecutar,0)), 
	 PlanAct = isnull(lpamD.CantidadEjecutar,0), 
     AnioMes = ((DATEPART(year, pc.Inicio) + (t1.NumeroAnio - 1)) * 100) + t1.NumeroMes
	 ,lpamD.Id
     INTO #tmpPlan
     FROM CO_LineaProgramaActividadMes t1
          INNER JOIN CO_ActividadPetroleraCNH ON t1.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
          INNER JOIN CO_SubactividadPetrolera ON t1.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
          INNER JOIN CO_TareaPetrolera ON t1.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
          INNER JOIN CO_Servicio ON t1.IdSubTareaPetrolera = CO_Servicio.IdServicio
          INNER JOIN CO_ProgramaActividad pa ON pa.IdProgramaActividad = t1.IdProgramaActividad
          INNER JOIN CO_PeriodoContrato pc ON pc.IdPeriodo = pa.IdPeriodoContrato
		  left join CO_LineaProgramaActividadMesDetalle as lpamD on lpamD.IdLineaProgramaActividadMes = t1.IdLineaProgramaActividadMes
     --inner join #tmpPrincipal tmpPrin on tmpPrin.IdLineaProgramaActividadMes = t1.IdLineaProgramaActividadMes
WHERE pc.IdContrato = @pidContrato
           AND t1.IdProgramaActividad = @pIdProgramaActividad
		   group by 
		   CO_Servicio.IdServicio
		   , pa.IdProgramaActividad
		   , CO_ActividadPetroleraCNH.IdActividadPetrolera
		   , CO_SubactividadPetrolera.IdSubactividadPetrolera
		   , CO_TareaPetrolera.IdTareaPetrolera
		   , CO_ActividadPetroleraCNH.id_Actividad
		   , lpamD.CantidadEjecutar
		   , pc.Inicio, t1.NumeroAnio, t1.NumeroMes
		   , lpamD.Id;

	 

     DECLARE @fechaIniAct INT, @fechaFinAct INT, @fechaAux INT, @consecutivo INT= 1;
     SELECT @fechaIniAct = MIN(AnioMes), 
            @fechaFinAct = MAX(AnioMes), 
            @fechaAux = MIN(AnioMes)
     FROM #tmpPlan;

     /**/

     CREATE TABLE #tmpAnioMes
     (AnioMes     INT, 
      Consecutivo INT
     );
     WHILE @fechaAux <= @fechaFinAct
         BEGIN
             INSERT INTO #tmpAnioMes
             (AnioMes, 
              Consecutivo
             )
                    SELECT @fechaAux, 
                           @consecutivo;
             SELECT @consecutivo = @consecutivo + 1;
             SELECT @fechaAux = @fechaAux + 1;
         END;

     /**/

	 

     SELECT --IdLineaProgramaActividadMes,		
     IdProgramaActividad, 
     IdActividadPetrolera, 
     IdSubactividadPetrolera, 
     IdTareaPetrolera, 
     id_Actividad, 
     IdServicio, 
	 Id,
     [1] AS mes1, 
     [2] AS mes2, 
     [3] AS mes3, 
     [4] AS mes4, 
     [5] AS mes5, 
     [6] AS mes6, 
     [7] AS mes7, 
     [8] AS mes8, 
     [9] AS mes9, 
     [10] AS mes10, 
     [11] AS mes11, 
     [12] AS mes12, 
     [13] AS mes13, 
     [14] AS mes14, 
     [15] AS mes15, 
     [16] AS mes16, 
     [17] AS mes17, 
     [18] AS mes18, 
     [19] AS mes19, 
     [20] AS mes20, 
     [21] AS mes21, 
     [22] AS mes22, 
     [23] AS mes23, 
     [24] AS mes24, 
     [25] AS mes25, 
     [26] AS mes26, 
     [27] AS mes27, 
     [28] AS mes28, 
     [29] AS mes29, 
     [30] AS mes30, 
     [31] AS mes31, 
     [32] AS mes32, 
     [33] AS mes33, 
     [34] AS mes34, 
     [35] AS mes35, 
     [36] AS mes36, 
     [37] AS mes37, 
     [38] AS mes38, 
     [39] AS mes39, 
     [40] AS mes40
     INTO #tmpPivote
     FROM
     (
         SELECT --IdLineaProgramaActividadMes,
         IdProgramaActividad, 
         IdActividadPetrolera, 
         IdSubactividadPetrolera, 
         IdTareaPetrolera, 
         id_Actividad, 
         IdServicio, 
         PlanAct, 
         tmpAnio.AnioMes, 
         tmpAnio.Consecutivo
		 ,Id
         FROM #tmpAnioMes tmpAnio
         INNER JOIN #tmpPlan tmpPlan ON tmpPlan.AnioMes = tmpAnio.AnioMes
     ) t PIVOT(max(PlanAct) FOR Consecutivo IN([1], 
                                               [2], 
                                               [3], 
                                               [4], 
                                               [5], 
                                               [6], 
                                               [7], 
                                               [8], 
                                               [9], 
                                               [10], 
                                               [11], 
                                               [12], 
                                               [13], 
                                               [14], 
                                               [15], 
                                               [16], 
                                               [17], 
                                               [18], 
                                               [19], 
                                               [20], 
                                               [21], 
                                               [22], 
                                               [23], 
                                               [24], 
                                               [25], 
                                               [26], 
                                               [27], 
                                               [28], 
                                               [29], 
                                               [30], 
											   [31], 
                                               [32], 
                                               [33], 
                                               [34], 
                                               [35], 
                                               [36], 
                                               [37], 
                                               [38], 
                                               [39], 
                                               [40])) AS pvt;

	

     /**/
	 --select * from #tmpPivote where IdServicio = 10122
     SELECT Id, 
	 IdProgramaActividad, 
            IdActividadPetrolera, 
            IdSubactividadPetrolera, 
            IdTareaPetrolera, 
            id_Actividad, 
            IdServicio
			, 
            mes1 = sum(mes1), 
            mes2 = sum (mes2), 
            mes3 = SUM(mes3), 
            mes4 = SUM(mes4), 
            mes5 = SUM(mes5), 
            mes6 = SUM(mes6), 
            mes7 = SUM(mes7), 
            mes8 = SUM(mes8), 
            mes9 = SUM(mes9), 
            mes10 = SUM(mes10), 
            mes11 = SUM(mes11), 
            mes12 = SUM(mes12), 
            mes13 = SUM(mes13), 
            mes14 = SUM(mes14), 
            mes15 = SUM(mes15), 
            mes16 = SUM(mes16), 
            mes17 = SUM(mes17), 
            mes18 = SUM(mes18), 
            mes19 = SUM(mes19), 
            mes20 = SUM(mes20), 
            mes21 = SUM(mes21), 
            mes22 = SUM(mes22), 
            mes23 = SUM(mes23), 
            mes24 = SUM(mes24), 
            mes25 = SUM(mes25), 
            mes26 = SUM(mes26), 
            mes27 = SUM(mes27), 
            mes28 = SUM(mes28), 
            mes29 = SUM(mes29), 
            mes30 = SUM(mes30), 
            mes31 = SUM(mes31), 
            mes32 = SUM(mes32), 
            mes33 = SUM(mes33), 
            mes34 = SUM(mes34), 
            mes35 = SUM(mes35), 
            mes36 = SUM(mes36), 
            mes37 = SUM(mes37), 
            mes38 = SUM(mes38), 
            mes39 = SUM(mes39), 
            mes40 = SUM(mes40)
     INTO #tmpPivote2
     FROM #tmpPivote
     GROUP BY IdProgramaActividad, 
              IdActividadPetrolera, 
              IdSubactividadPetrolera, 
              IdTareaPetrolera, 
              id_Actividad,
			  Id,
              IdServicio;
     DECLARE @meses INT;
     SELECT @meses = MAX(consecutivo)
     FROM #tmpAnioMes;





	
	 



     /**/
	 --select * from #tmpPivote2
     --/**********Resultado FINAL************************/
     SELECT 
	 --distinct 
	 t2.IdLineaProgramaActividadMes, 
            t1.IdProgramaActividad, 
            t1.IdActividadPetrolera, 
            t1.IdSubactividadPetrolera, 
            t1.IdTareaPetrolera, 
            t1.IdServicio, 
            TPA.TipoPrograma AS Programa, 
            CO_ActividadPetroleraCNH.DescripcionActividadPetrolera, 
            CO_SubactividadPetrolera.SubactividadPetrolera, 
            CO_TareaPetrolera.TareaPetrolera, 
            SubTareaPetrolera = CO_Servicio.NombreServicio, 
            NumeroAnio, 
            NumeroMes, 
            Actividades, 
            Fecha, 
            t1.Id, 
            CantidadEjecutar = isnull(CantidadEjecutar, 0), 
			--CantidadEjecutar = SUM(isnull(CantidadEjecutar, 0)), 
            UTUnidad, 
            FechaInicio, 
            FechaFin, 
            Comentarios, 
            t2.CreadoEl, 
            t2.CreadoPor, 
            UnidadServicio = uniS.Unidad, 
            AcreditaUT, 
            UTSTotales, 
            mes1 = isnull(mes1,0), 
            mes2= isnull(mes2,0), 
            mes3= isnull(mes3,0), 
            mes4= isnull(mes4,0), 
            mes5= isnull(mes5,0), 
            mes6= isnull(mes6,0), 
            mes7= isnull(mes7,0), 
            mes8= isnull(mes8,0), 
            mes9= isnull(mes9,0), 
            mes10= isnull(mes10,0), 
            mes11= isnull(mes11,0), 
            mes12= isnull(mes12,0), 
            mes13= isnull(mes13,0), 
            mes14= isnull(mes14,0), 
            mes15= isnull(mes15,0), 
            mes16= isnull(mes16,0), 
            mes17= isnull(mes17,0), 
            mes18= isnull(mes18,0), 
            mes19= isnull(mes19,0), 
            mes20= isnull(mes20,0), 
            mes21= isnull(mes21,0), 
            mes22= isnull(mes22,0), 
            mes23= isnull(mes23,0), 
            mes24= isnull(mes24,0), 
            mes25= isnull(mes25,0), 
            mes26= isnull(mes26,0), 
			mes27= isnull(mes27,0), 
            mes28= isnull(mes28,0), 
            mes29= isnull(mes29,0), 
            mes30= isnull(mes30,0), 
            mes31= isnull(mes31,0), 
            mes32= isnull(mes32,0), 
            mes33= isnull(mes33,0), 
            mes34= isnull(mes34,0), 
            mes35= isnull(mes35,0), 
            mes36= isnull(mes36,0), 
            mes37= isnull(mes37,0), 
            mes38= isnull(mes38,0), 
            mes39= isnull(mes39,0), 
            mes40= isnull(mes40,0), 
            Meses = CASE
                        WHEN isnull(@meses, 0) > 40
                        THEN 40
                        ELSE @meses
                    END, 
            Total = isnull(mes1, 0) + isnull(mes2, 0) + isnull(mes3, 0) + isnull(mes4, 0) + isnull(mes5, 0) + isnull(mes6, 0) + isnull(mes7, 0) + isnull(mes8, 0) + isnull(mes9, 0) + isnull(mes10, 0) + 
					isnull(mes11, 0) + isnull(mes12, 0) + isnull(mes13, 0) + isnull(mes14, 0) +  isnull(mes15, 0) + isnull(mes16, 0) + isnull(mes17, 0) + isnull(mes18, 0) + isnull(mes19, 0) + isnull(mes20, 0) + 
					isnull(mes21, 0) + isnull(mes22, 0) + isnull(mes23, 0) +  isnull(mes24, 0) + isnull(mes25, 0) + isnull(mes26, 0) + isnull(mes27, 0) + isnull(mes28, 0) + isnull(mes29, 0) + isnull(mes30, 0) + 
					isnull(mes31, 0) + isnull(mes32, 0) +  isnull(mes33, 0) + isnull(mes34, 0) + isnull(mes35, 0) + isnull(mes36, 0) +  isnull(mes37, 0) + isnull(mes38, 0) + isnull(mes39, 0) + isnull(mes40, 0)
     FROM #tmpPivote2 t1
          INNER JOIN CO_ActividadPetroleraCNH ON t1.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
          INNER JOIN CO_SubactividadPetrolera ON t1.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
          INNER JOIN CO_TareaPetrolera ON t1.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
          INNER JOIN CO_Servicio ON t1.idServicio = CO_Servicio.IdServicio
          INNER JOIN CO_Unidad uniS ON uniS.IdUnidad = CO_Servicio.IdUnidad
          INNER JOIN dbo.CO_ProgramaActividad PA ON t1.IdProgramaActividad = PA.IdProgramaActividad
          INNER JOIN dbo.CO_TipoProgramaActividad TPA ON PA.IdTipoProgramaActividad = TPA.IdTipoProgramaActividad
          LEFT JOIN #tmpPrincipal t2 ON t2.IdProgramaActividad = t1.IdProgramaActividad
                                        AND t2.IdActividadPetrolera = t1.IdActividadPetrolera
                                        AND t2.IdSubactividadPetrolera = t1.IdSubactividadPetrolera
                                        AND t2.IdTareaPetrolera = t1.IdTareaPetrolera
                                        AND t2.IdServicio = t1.IdServicio 
										and t1.Id = t2.Id

	-- RETORNA LOS MESES EN FORMA DE LISTA DESDE LA FECHA INICIO HASTA LA FECHA FIN
	SET Language 'Spanish';
	declare @start DATE = getdate()
	declare @end DATE = getdate()

	SELECT @start =  isnull(Inicio, getdate()), @end = isnull(Fin, getdate()) FROM CO_PeriodoContrato WHERE IdPeriodo = @pIdPeriodo
		
	;with months (date)
	AS
	(
	SELECT @start
	UNION ALL
	SELECT DATEADD(month, 1, date)
	from months
	where DATEADD(month, 1, date) < @end
	)
	select     CONCAT(DATENAME(mm, date), '-' , DATEPART(yy, date))
	from months

END