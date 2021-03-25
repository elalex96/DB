ALTER PROCEDURE ObtenerInfoSolped
@IdSolicitudPedido INT,
@IdProveedor INT
AS
BEGIN

    SELECT distinct
	p.RazonSocial, 
	sp.FechaAlta, 
	sp.IdPeriodo, 
	sp.IdPresupuesto, 
	sp.MotivoUrgencia,
	 spd.IdMaterial, 
	 spd.Cantidad, 
	 spd.IdDomicilioEntrega, 
	 spd.IdUnidad, 
	 spd.observaciones,
	 spdl.IdCentroCosto, 
	 spdl.IdInstalacion, 
	 spdl.IdLineaPresupuesto, 
	 spd.IdSolicitudPedidoDetalle, 
	 per.NombrePeriodo, 
	 CONCAT(pres.Nombre, ' [ ',pres.IdPresupuestoCNH,' ]') AS Presupuesto,
	 e.Nombre AS Estatus, sp.PeticionEnviada
	 , I.NombreInstalacion
	 ,
               CONCAT(
               'Mes Programado: ',
               RIGHT('00' + LTRIM(MONTH(lpm.AC_PRESUP_MES)), 2),
               ' ',
               dbo.Fn_RetornarMesEspanol(MONTH(lpm.AC_PRESUP_MES)),
               ' ',
               YEAR(lpm.AC_PRESUP_MES),
               ' | Actividad: ',
    
           CASE
                   WHEN CO.IdTipoContrato = 1 THEN
                       TS.NombreTipoServicio
                   ELSE
                       APCNH.DescripcionActividadPetrolera
               END COLLATE Modern_Spanish_CI_AS,            
   -- Actividad
               ' | Sub-Actividad: ',
               CASE
                   WHEN CO.IdTipoContrato = 1 THEN
                       ACIEP.NombreActividad
                   ELSE
                       SAP.SubactividadPetrolera
             
  END COLLATE Modern_Spanish_CI_AS,               -- SubActividad
               ' | Tarea: ',
               TP.TareaPetrolera COLLATE Modern_Spanish_CI_AS, -- Tarea
               ' | Clave Tarea: ',
               TP.id_Tarea COLLATE Modern_Spanish_CI_AS,       -- Clave Tarea
               ' | Sub-Tarea: ',
               S.NombreServicio COLLATE Modern_Spanish_CI_AS) -- Sub Tarea  
               AS subTarea
	FROM dbo.MM_SolicitudPedido sp 
	INNER JOIN dbo.MM_SolicitudPedidoDetalle spd 
	ON sp.IdSolicitudPedido = spd.IdSolicitudPedido 
	INNER JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdl 
	ON spd.IdSolicitudPedidoDetalle = spdl.IdSolicitudPedidoDetalle 
	INNER JOIN dbo.TA_Operacion tao 
	ON tao.IdDocumento = @IdSolicitudPedido AND tao.IdTipoOperacion = 2
	LEFT JOIN dbo.S_Proveedor p 
	ON sp.IdProveedor = p.IdProveedor 
	LEFT JOIN Adinco.dbo.CO_PeriodoContrato per 
	ON sp.IdPeriodo = per.IdPeriodo 
	LEFT JOIN Adinco.dbo.CO_Presupuesto pres 
	ON sp.IdPresupuesto = pres.IdPresupuesto 
	LEFT JOIN dbo.TA_Estatus e 
	ON tao.IdEstatusOperacion = e.IdEstatus 
	JOIN Adinco..CO_Instalacion I 
	on spdl.IdInstalacion = I.IdInstalacion
	----------------------------------------
	JOIN Adinco.dbo.CO_LineaPresupuestoMes lpm 
	ON spdl.IdLineaPresupuesto = lpm.IdLineaPresupuestoMes
	LEFT JOIN Adinco.dbo.CO_Registro R
                ON lpm.IdLineaPresupuestoMes = R.IdPrograma
            LEFT JOIN Adinco.dbo.FI_Factura F
                ON R.IdFactura = F.IdFactura
            LEFT JOIN Adinco.dbo.CO_TipoCambioDiario TCD
                ON F.IdMoneda = TCD.IdMoneda
                   AND YEAR(TCD.Fecha) = YEAR(F.Fecha)
                   AND MONTH(TCD.Fecha) = MONTH(F.Fecha)
                   AND DAY(TCD.Fecha) = DAY(F.Fecha)
            LEFT JOIN Adinco.dbo.CO_Presupuesto PR
                ON lpm.IdPresupuesto = PR.IdPresupuesto 
            LEFT JOIN Adinco.dbo.CO_AnioContractual AC
                ON PR.IdAnioContractual = AC.IdAnioContractual 
            LEFT JOIN Adinco.dbo.CO_Contrato CO
                ON AC.IdContrato = CO.IdContrato 
            LEFT JOIN Adinco.dbo.CO_ActividadPetroleraCNH APCNH
                ON lpm.IdActividadPetrolera = APCNH.IdActividadPetrolera
            LEFT JOIN Adinco.dbo.CO_SubactividadPetrolera SAP
                ON lpm.IdSubactividadPetrolera = SAP.IdSubactividadPetrolera
  
          LEFT JOIN Adinco.dbo.CO_TareaPetrolera TP
                ON lpm.IdTareaPetrolera = TP.IdTareaPetrolera
            LEFT JOIN Adinco.dbo.CO_ActividadCIEP AS ACIEP
                ON lpm.IdActividad = ACIEP.IdActividad
            LEFT JOIN Adinco.dbo.CO_TipoServicio TS
                ON lpm.IdTipoServicio = TS.ID_TIPOSER
            LEFT JOIN Adinco.dbo.CO_Servicio S
                ON lpm.IdServicio = S.IdServicio
            LEFT JOIN Adinco.dbo.CO_Instalacion Ins
                ON lpm.IdInstalacion = Ins.IdInstalacion
	WHERE sp.IdSolicitudPedido = @IdSolicitudPedido AND sp.IdProveedor = @IdProveedor
END

