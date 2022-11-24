-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <19-09-2018>
-- Description:	<Se consulta el usuario que aprobo o rechazo la factura>
-- =============================================
-- Author:		Luis David
-- Create date: 17/06/2022
-- Description:	Se quita la duplicidad de aprobadores
-- =============================================

-- SP_MPY_ConsultarAprobadoresCompraDirecta 4183,0
CREATE PROCEDURE SP_MPY_ConsultarAprobadoresCompraDirecta  
@IdAceptacionPedido int,
@IdProveedor NVARCHAR(20) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--SELECT AFI.IdAprobador_FI, AFI.Nombre, AFI.Correo, E.Nombre AS EstatusAprobacion,AFI.Comentario,AFI.FechaEvaluacion
	--FROM dbo.MPY_FI_Aprobadores AS AFI
	--LEFT JOIN dbo.TA_Estatus AS E ON E.IdEstatus = AFI.EstatusAprobacion
	--WHERE IdAceptacionPedido = @IdAceptacionPedido --AND IdProveedor = @IdProveedor

	--- TT.IdEstatus = 2
	DROP TABLE IF EXISTS #AprobacionAceptacionHistorial
	CREATE TABLE #AprobacionAceptacionHistorial
	(
		IdAprobador_FI INT,
		Nombre varchar(500),
		Correo varchar(500),
		EstatusAprobacion varchar(500),
		Comentario varchar(500),
		FechaEvaluacion datetime
	)

	INSERT INTO #AprobacionAceptacionHistorial
	SELECT u.IdUsuario AS IdAprobador_FI,
		u.Nombre,
		u.Correo, 
		t.Nombre AS EstatusAprobacion,
		af.Comentario,
		af.FechaAprobacion as FechaEvaluacion
	FROM dbo.MPY_MM_AceptacionFactura af
	left JOIN dbo.S_Usuario u ON af.IdAprobador = u.IdUsuario
	left JOIN dbo.TA_estatus t ON  af.IdEstatus = t.IdEstatus 
	WHERE af.IdAceptacionPedido = @IdAceptacionPedido
	union
	SELECT u.IdUsuario AS IdAprobador_FI,
		u.Nombre,
		u.Correo, 
		t.Nombre AS EstatusAprobacion,
		af.Comentario,
		af.FechaAprobacion as FechaEvaluacion
	FROM dbo.MPY_MM_AceptacionFactura_bitacora af
	inner join MPY_MM_AceptacionFactura af1 on af1.IdAceptacionFactura = af.IdAceptacionFactura
	left JOIN dbo.S_Usuario u ON af.IdAprobador = u.IdUsuario
	left JOIN dbo.TA_estatus t ON  af.IdEstatus = t.IdEstatus 
	WHERE af1.IdAceptacionPedido = @IdAceptacionPedido
	

	SELECT 
		IdAprobador_FI ,
		Nombre ,
		Correo ,
		EstatusAprobacion ,
		Comentario ,
		FechaEvaluacion 
	FROM #AprobacionAceptacionHistorial
	GROUP BY IdAprobador_FI ,
		Nombre ,
		Correo ,
		EstatusAprobacion ,
		Comentario ,
		FechaEvaluacion

END
