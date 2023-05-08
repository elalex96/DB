-- =============================================
-- Author:		Manuel Cruz
-- Create date: 04-07-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ProveedoresPorMaterial]-- 12283,420,
	-- Add the parameters for the stored procedure here
	@IdSolicitudPedido INT,
	@idProveedor INT,
	@Indicador int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	 
	 -- Insert statements for procedure here
	
	--SELECT P.IdProveedor, P.RazonSocial,SPD.IdMaterial,MSF.IdSubFamilia,MSF.SubFamilia
	--FROM MM_SolicitudPedido SP
	--JOIN MM_SolicitudPedidoDetalle SPD ON SP.IdSolicitudPedido = SPD.IdSolicitudPedido
	--JOIN MM_MaterialesVentaProveedor MVP ON SPD.IdMaterial = MVP.IdMaterial
	--JOIN MM_Material M ON MVP.IdMaterial = M.IdMaterial
	--JOIN PV_MM_MaterialSubFamilia MSF ON M.IdSubFamilia = MSF.IdSubFamilia
	--JOIN S_Proveedor P ON M.IdProveedor = P.IdProveedor
	--WHERE SP.IdSolicitudPedido = @IdSolicitudPedido --AND MSF.IdSubFamilia = @IdSubfamilia

	--EXEC SP_MM_ProveedoresPorMaterial 11197 11146


	--SELECT DISTINCT P.IdProveedor, P.RazonSocial,M.IdMaterial, MSF.IdSubfamilia, MSF.SubFamilia, M.[DescripcionCorta]
	--FROM S_Proveedor P  
	--INNER JOIN MM_Material M ON M.IdProveedor = P.IdProveedor
	--INNER JOIN MM_MaterialesVentaProveedor MVP ON MVP.IdMaterial =  M.IdMaterial
	--INNER JOIN PV_MM_MaterialSubFamilia MSF ON M.IdSubFamilia = MSF.IdSubFamilia
	--INNER JOIN MM_SolicitudPedidoDetalle SPD ON SPD.IdMaterial = MSF.IdSubFamilia
	--INNER JOIN MM_SolicitudPedido SP ON SP.IdSolicitudPedido = SPD.IdSolicitudPedido
	--LEFT JOIN DG_EvaluacionComercial_Proveedor AS ECP ON ECP.IdProveedorEvaluado = P.IdProveedor
	--WHERE SP.IdSolicitudPedido =11152


	DECLARE @TOTAL_RESULTADOS INT = 0
	DECLARE @ROW INT = 1
	DECLARE @COUNT_1 INT 
	DECLARE @COUNT_2 INT
	DECLARE @COUNT_3 INT
	DECLARE @COUNT_4 INT
	DECLARE @COUNT_5 INT 
	DECLARE @EVALUACION_PROMEDIO FLOAT
	DECLARE @EVALUACION_ESPERADA INT
    DECLARE @TOTAL_EVALUADORES INT  
	DECLARE @IdProveedorActual INT 

	CREATE TABLE #PROVEEDORES_FILTRO(IdRow int, IdProveedor int, NombreProveedor nvarchar(max), EvaluacionComercial float, Correo nvarchar(300), NombreUsuarioVentas nvarchar(300), Ubicacion nvarchar(500))

	INSERT INTO #PROVEEDORES_FILTRO(IdRow, IdProveedor, NombreProveedor,EvaluacionComercial,Correo,NombreUsuarioVentas,Ubicacion)
	SELECT   ROW_NUMBER() OVER(ORDER BY P.IdProveedor ASC) AS Row#,P.IdProveedor, P.RazonSocial, 0 AS EvaluacionComercial, U.Correo, U.Nombre, (P.Municipio +' - '+ P.Entidad) as Ubicacion
	FROM S_Proveedor P  
	INNER JOIN MM_Material M ON M.IdProveedor = P.IdProveedor
	INNER JOIN MM_MaterialesVentaProveedor MVP ON MVP.IdMaterial =  M.IdMaterial
	INNER JOIN MM_Maestro MSF ON M.IdMaestro = MSF.IdMaestro
	JOIN MM_SolicitudPedidoDetalle SPD ON SPD.IdMaterial = MSF.IdMaestro
	INNER JOIN MM_SolicitudPedido SP ON SP.IdSolicitudPedido = SPD.IdSolicitudPedido
	INNER JOIN S_UsuarioProveedor AS UP ON UP.IdProveedor = P.IdProveedor
	INNER JOIN S_Usuario AS U ON U.IdUsuario = UP.IdUsuario
	WHERE SP.IdSolicitudPedido =@IdSolicitudPedido AND U.IdTipoUsuario = 4 AND P.IdProveedor NOT IN (@idProveedor)
	GROUP BY P.IdProveedor, P.RazonSocial,U.Correo,U.Nombre, P.Municipio, P.Entidad
	 ---U.IdTipoUsuario = 4 Ventas
	SET @TOTAL_RESULTADOS = (SELECT COUNT(IdRow) FROM #PROVEEDORES_FILTRO)

	 

	WHILE @ROW <= @TOTAL_RESULTADOS   

	BEGIN 
		
		SET @IdProveedorActual  = (SELECT (IdProveedor) FROM #PROVEEDORES_FILTRO WHERE IdRow = @ROW)
				
		SET @TOTAL_EVALUADORES = (SELECT  COUNT(IdProveedorEvaluador) 
								FROM DG_EvaluacionComercial_Proveedor
								WHERE IdProveedorEvaluado = @IdProveedorActual) 
		 
		IF  @TOTAL_EVALUADORES > 0  
		BEGIN 
		SET @EVALUACION_ESPERADA = @TOTAL_EVALUADORES * 5;

		SET @COUNT_1 =(SELECT  COUNT(IdProveedorEvaluador) * 1
		FROM DG_EvaluacionComercial_Proveedor AS E
		WHERE E.IdProveedorEvaluado = @IdProveedorActual  AND E.Evaluacion =1)

		SET @COUNT_2 =(SELECT  COUNT(IdProveedorEvaluador) * 2
		FROM DG_EvaluacionComercial_Proveedor AS E
		WHERE E.IdProveedorEvaluado = @IdProveedorActual  AND E.Evaluacion =2)

		SET @COUNT_3 =(SELECT  COUNT(IdProveedorEvaluador) * 3
		FROM DG_EvaluacionComercial_Proveedor AS E
		WHERE E.IdProveedorEvaluado = @IdProveedorActual  AND E.Evaluacion =3)

		SET @COUNT_4 =(SELECT  COUNT(IdProveedorEvaluador) * 4
		FROM DG_EvaluacionComercial_Proveedor AS E
		WHERE E.IdProveedorEvaluado = @IdProveedorActual  AND E.Evaluacion =4)

		SET @COUNT_5 =(SELECT  COUNT(IdProveedorEvaluador) * 5
		FROM DG_EvaluacionComercial_Proveedor AS E
		WHERE E.IdProveedorEvaluado = @IdProveedorActual  AND E.Evaluacion =5)
				
		 
		SET @EVALUACION_PROMEDIO =((((@COUNT_1 + @COUNT_2+@COUNT_3 + @COUNT_4+ @COUNT_5)/1.00)/ (@EVALUACION_ESPERADA/1.0))/2)*10		 
		
		UPDATE #PROVEEDORES_FILTRO
		SET EvaluacionComercial = @EVALUACION_PROMEDIO 
		WHERE IdProveedor = @IdProveedorActual
		END 
		
		 
		SET @ROW = @ROW +1 
	END 
	
	---EXECUTE [dbo].[SP_MM_ProveedoresPorMaterial] 11152
	
	IF(@Indicador = 1)
	begin	
		SELECT IdProveedor, NombreProveedor,EvaluacionComercial, Correo, NombreUsuarioVentas, Ubicacion FROM  #PROVEEDORES_FILTRO
	END
    ELSE
    BEGIN
		SELECT 
		DISTINCT 
		P.IdProveedor,
		P.RazonSocial +' '+ P.RegimenCapital AS RazonSocial
		---u.Correo, u.Contrasena
		FROM S_Proveedor AS P
		INNER JOIN S_UsuarioProveedor AS UP ON UP.IdProveedor = P.IdProveedor
		INNER JOIN S_Usuario AS U ON U.IdUsuario = UP.IdUsuario   
		WHERE  U.IdTipoUsuario = 4 AND U.ACTIVO= 1 AND P.Activo = 1 AND (U.Contrasena IS NOT NULL)
		AND p.IdProveedor NOT IN (SELECT IdProveedor FROM #PROVEEDORES_FILTRO)
		AND P.IdProveedor NOT IN (@idProveedor)
	end

END


