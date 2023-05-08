
-- [MPY_SP_ConsultarAprobadoresNotaCredito]  88,100001,0,0,0
CREATE  PROCEDURE [dbo].[MPY_SP_ConsultarAprobadoresNotaCredito]  
@IdAceptacionPedido int,
@IdAceptacionNotaCredito int,
@IdOperacion int,
@IdProveedor INT,
@IdUsuario INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	--SELECT TT.IdAprobador, 
	--TT.NoSecuencia, 
	--U.Nombre as Aprobadores, 
	--TT.IdEstatus, 
	--TE.Nombre AS NombreEstatus, 
	--ISNULL(TT.Comentario,'') AS Comentario, 
	--ISNULL(FORMAT(TT.FechaCambioEstatus, 'dd/MM/yyyy hh:mm tt'),'') AS FechaCambioEstatus, 
	--TT.IdTarea, 
	--TT.IdOperacion, 
	--CASE WHEN UA.Nombre IS NULL THEN 
	--	'Asignado por el flujo predeterminado'
	--ELSE 
	--CONCAT(UA.Nombre, 
	--		' el día ', ISNULL(FORMAT(TT.FechaRegistro,'dd/MM/yyyy hh:mm tt'),''),
	--		(CASE WHEN LEN(ISNULL(TT.MensajeAsignacion,''))>0 THEN ' Mensaje:'+TT.MensajeAsignacion ELSE '' END)	
	--)
	--END  AS Asignador, 
	--TAO.IdEstatusOperacion  AS EstatusFactura	
	--FROM TA_Tarea TT 	
	--INNER JOIN TA_Operacion TAO ON TT.IdOperacion = TAO.IdOperacion
	--LEFT JOIN S_Usuario U	ON U.IdUsuario = TT.IdAprobador	
	--LEFT JOIN TA_Estatus TE ON TE.IdEstatus = TT.IdEstatus	
	--LEFT JOIN dbo.S_Usuario UA ON TT.AsignadoPor= UA.IdUsuario
	--WHERE   TAO.IdTipoOperacion = 17 ---> APROBACIÓN DE NOTA DE CREDITO
	-- AND TT.IdOperacion= @IdOperacion
	-- AND TT.Activo=1
	--ORDER BY TT.NoSecuencia ASC


	 SELECT 
		 IdAprobador = US.IdUsuario, 
		 NoSecuencia = 1,
		 Aprobadores=	 US.Nombre, 
		 IdEstatus = 1,
		 NombreEstatus = e.Nombre,
		 Comentario = isnull(anc.Comentario,''),
		 FechaCambioEstatus = getdate(),
		 IdTarea = 0,
		 IdOperacion = 0,
		 Asignador = '',
		 EstatusFactura = '',
		 US.Correo,
		 US.IdTipoUsuario
	FROM dbo.MPY_MM_AceptacionPedido ap 
	inner join MPY_MM_AceptacionFactura af on af.IdAceptacionPedido = ap.IdAceptacionPedido
	inner join [MPY_MM_AceptacionNotaCredito] anc on anc.IdAceptacionPedido =  ap.IdAceptacionPedido and
													anc.IdAceptacionNotaCredito = @IdAceptacionNotaCredito
	inner join TA_Estatus e on e.IdEstatus = anc.IdEstatus
	LEFT JOIN Adinco.dbo.CO_Contratista AS CO ON CO.IdContratista = ap.IdProveedor
	LEFT JOIN dbo.S_Proveedor AS PR ON PR.RFC COLLATE Modern_Spanish_CI_AS = CO.RFC COLLATE Modern_Spanish_CI_AS	
	LEFT JOIN dbo.S_Usuario AS US ON US.IdUsuario = af.IdAprobador
	WHERE ap.IdAceptacionPedido = @IdAceptacionPedido
		AND US.Activo = 1
		--AND ISNULL(US.IsEliminado, 0) = 0
		--AND US.IdUsuario IS NOT NULL
	GROUP BY US.IdUsuario, US.Nombre, US.Correo,US.IdTipoUsuario, e.Nombre,anc.Comentario

	--- TT.IdEstatus = 2
END

 

