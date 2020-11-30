-- =============================================
-- Author:		Abel Rivera
-- Update date: 01/12/17 
-- Description:	
-- =============================================
-- Author:		Pedro Acuña
-- Update date: 17/01/2018 
-- Description:	se modifica que solo se muestren los giros activos
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <26-03-2018>
-- Description:	<Se agrega columna VerDetalle para ocultar este boton>
-- =============================================
-- Author:		<Pedro, Acuña>
-- Create date: <05-11-2018>
-- Description:	<correos de los proveedores>. 
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 15/Jul/2019
-- Description:	se agrego la lista negra del sat
-- =============================================
-- Author:		Abel Rivera
-- Create date: 26/ago/2019
-- Description:	se agrego un campo para validar si el proveedor esta en la lista negra
-- =============================================

CREATE PROCEDURE [dbo].[SP_MM_ProveedoresPorMaterialCat] --0,420,0,0,0
    -- Add the parameters for the stored procedure here
    @IdMaterialMaestro INT,
	@IdProveedor2 INT,
    /*--------------------   parametros contrato  --------------------*/
    @IdContrato INT,
    @IdUsuario INT,
    @FechaRegistro DATETIME
/*----------------------------------------*/
AS
BEGIN
    
    CREATE TABLE #TEMP_PROVEEDORES --CREAMOS UNA TABLA TEMPORAL
    (
        IdRow INT,
        IdProveedor INT,
        RFC NVARCHAR(MAX),
        RazonSocial NVARCHAR(MAX),
        IdNacionalidad INT,
        Nacionalidad NVARCHAR(MAX),
        Pais NVARCHAR(MAX),
        Entidad NVARCHAR(MAX),
        Municipio NVARCHAR(MAX),
        GiroProveedor NVARCHAR(MAX),
        ClasificacionPyMES_Nombre NVARCHAR(MAX),
        Contacto NVARCHAR(MAX),
        Telefono NVARCHAR(200),
        Email NVARCHAR(300),
		VerDetalle BIT,
		InBlackList BIT
    )

    DECLARE @INCREMENTO INT = 1, --- DECLARAMOS LAS VARIABLES NECESARIAS
            @COUNT_PROVEEDORES INT,
            @IDPROVEEDOR INT,
            @GIROS NVARCHAR(MAX),
			@IDCONTRATISTA INT
			

			SET @IDCONTRATISTA = (SELECT TOP 1 ci.IdContratista FROM dbo.S_Proveedor AS pr
			LEFT JOIN Adinco.dbo.CO_Contratista AS ci ON pr.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = ci.RFC COLLATE SQL_Latin1_General_CP1_CI_AS 
			WHERE pr.IdProveedor=@IdProveedor2)

			IF ISNULL(@IdContrato,0) = 0 
			
			BEGIN
			SET @IdContrato = (SELECT TOP 1 co.IdContrato FROM adinco.dbo.CO_Contrato AS co
			WHERE co.IdContratista = @IDCONTRATISTA			
			)
			end

			                                       

    IF (@IdMaterialMaestro > 0) -- DEPENDIENDO LA CONDICIÓN EL RESULTADO CAMBIARA 
    BEGIN
        --# Donde M.IdTipoProveedor=2 -->  Proveedor Petrovendor
        INSERT INTO #TEMP_PROVEEDORES
        SELECT ROW_NUMBER() OVER (ORDER BY P.IdProveedor ASC),
               P.IdProveedor,
               P.RFC,
               CASE
				WHEN LN.RFC IS NULL THEN P.RazonSocial 
				ELSE CONCAT ( P.RazonSocial ,  ' - DESHABILITADO POR SAT - [Situación: ', LN.Situacion COLLATE Modern_Spanish_CI_AS,']')
				END AS RazonSocial,
               P.IdNacionalidad,
               n.Nacionalidad,
               P.Pais,
               P.Entidad,
               P.Municipio,
               NULL,
               CPY.Nombre AS Clasificacion,
               '',
               P.Telefono,
               dbo.Fn_ObtenerCorreoVentasoAdministrador(P.IdProveedor) AS CorreoProveedor,
			   0,
			   CASE WHEN LN.RFC  IS NULL THEN 0 ELSE 1 END AS InBlackList
        FROM dbo.S_Proveedor AS P
            LEFT JOIN S_Nacionalidad n
                ON P.IdNacionalidad = n.IdNacionalidad
            LEFT JOIN MM_Material M
                ON M.IdProveedor = P.IdProveedor
            LEFT JOIN MM_Maestro MSF
                ON M.IdMaestro = MSF.IdMaestro
            LEFT JOIN dbo.PV_ClasificacionEmpresaProveedor AS CEP
                ON CEP.IdProveedor = P.IdProveedor
            LEFT JOIN dbo.PV_ClasificacionPyMES AS CPY
                ON CPY.IdClasificacion = CEP.IdClasificacionEmpresa
			LEFT JOIN Adinco.dbo.ListaNegra AS LN
				ON LN.RFC COLLATE Modern_Spanish_CI_AS = P.RFC COLLATE Modern_Spanish_CI_AS
        WHERE M.IdMaestro = @IdMaterialMaestro
              AND P.Activo = 1
              AND ISNULL(P.IsEliminado, 0) = 0
              AND M.IdTipoProveedor = 2
        GROUP BY P.IdProveedor,
                 P.RazonSocial,
                 P.RFC,
                 n.Nacionalidad,
                 P.IdNacionalidad,
                 P.Pais,
                 P.Entidad,
                 P.Municipio,
                 CPY.Nombre,
                 P.Telefono,
                 P.CorreoProveedor,
				 LN.RFC,
				 LN.Situacion

    END
    ELSE
    BEGIN

        INSERT INTO #TEMP_PROVEEDORES
        SELECT ROW_NUMBER() OVER (ORDER BY p.IdProveedor ASC),
               p.IdProveedor,
               P.RFC,
               CASE
				WHEN LN.RFC IS NULL THEN P.RazonSocial 
				ELSE CONCAT ( P.RazonSocial , ' - DESHABILITADO POR SAT - [Situación: ', LN.Situacion COLLATE Modern_Spanish_CI_AS,']')
				END AS RazonSocial,
               p.IdNacionalidad,
               n.Nacionalidad,
               Pais,
               Entidad,
               Municipio,
               NULL,
               CPY.Nombre AS Clasificacion,
               '',
               p.Telefono,
               dbo.Fn_ObtenerCorreoVentasoAdministrador(P.IdProveedor) AS CorreoProveedor,
			   0,
			   CASE WHEN LN.RFC  IS NULL THEN 0 ELSE 1 END AS InBlackList
        FROM Petrovendor.dbo.S_Proveedor p
            LEFT JOIN S_Nacionalidad n
                ON p.IdNacionalidad = n.IdNacionalidad
            LEFT JOIN dbo.PV_ClasificacionEmpresaProveedor AS CEP
                ON CEP.IdProveedor = p.IdProveedor
            LEFT JOIN dbo.PV_ClasificacionPyMES AS CPY
                ON CPY.IdClasificacion = CEP.IdClasificacionEmpresa
			LEFT JOIN Adinco.dbo.ListaNegra AS LN
				ON LN.RFC COLLATE Modern_Spanish_CI_AS = P.RFC COLLATE Modern_Spanish_CI_AS
        WHERE p.Activo = 1
              AND ISNULL(IsEliminado, 0) = 0
        GROUP BY p.IdProveedor,
                 p.RazonSocial,
                 p.RFC,
                 n.Nacionalidad,
                 p.IdNacionalidad,
                 p.Pais,
                 p.Entidad,
                 p.Municipio,
                 CPY.Nombre,
                 p.Telefono,
                 p.CorreoProveedor,
				 LN.RFC,
				 LN.Situacion
    END

    SET @INCREMENTO = 1
    SET @COUNT_PROVEEDORES = -- SE CONSULTA LA CANTIDAD DE PROVEEDORES 
    (
        SELECT COUNT(P.IdProveedor)
        FROM dbo.S_Proveedor P
        WHERE P.Activo = 1
              AND ISNULL(P.IsEliminado, 0) = 0
    )

    WHILE (@INCREMENTO < @COUNT_PROVEEDORES) -- CICLO PARA VERIFICAR LA CANTIDAD DE GIROS DE LA EMPRESA Y CONCATENARLOS EN UNA SOLA COLUMNA 
    BEGIN

        SET @IDPROVEEDOR =
        (
            SELECT IdProveedor FROM #TEMP_PROVEEDORES WHERE IdRow = @INCREMENTO
        )

        SET @GIROS =
        (
            SELECT SUBSTRING(
                   (
                       SELECT ', ' + RTRIM(GE.GiroProveedor) AS 'data()'
                       FROM dbo.S_Proveedor p
                           LEFT JOIN dbo.PV_PerfilGiroEmpresarial AS PGE
                               ON PGE.IdProveedor = p.IdProveedor
                           LEFT JOIN dbo.PV_GiroEmpresarial AS GE
                               ON GE.IdGiroProveedor = PGE.IdGiroEmpresarial -- METODO PARA CONCATENAR LOS GIROS EMPRESARIALES POR PROVEEDOR
                       WHERE p.IdProveedor = @IDPROVEEDOR
                             AND PGE.Activo = 1
                       FOR XML PATH('')
                   ),
                   2,
                   9999
                            ) AS giros
        )

        UPDATE #TEMP_PROVEEDORES --- ACTUALIZAMOS EL CAMPO DE LOS GIROS EMPRESARIALES 
        SET GiroProveedor = @GIROS
        WHERE IdProveedor = @IDPROVEEDOR

        SET @INCREMENTO = @INCREMENTO + 1

    END

    UPDATE temp --- ACTUALIZAMOS CAMPOS
    SET Contacto = CONCAT(contacto.Nombres, ' ', contacto.Apellidos)
    FROM #TEMP_PROVEEDORES temp
        INNER JOIN dbo.S_Contacto contacto
            ON temp.IdProveedor = contacto.IdProveedor
    	
	---  Activación de Detalles ---
	
	---------------------------if-------------------------
	

	IF @IdContrato IN (3,10037)
		BEGIN 
			UPDATE #TEMP_PROVEEDORES
			SET VerDetalle=1
			WHERE  RFC IN (SELECT TaxID FROM Adinco.dbo.CO_SAPVendor)
		END
	ELSE
		BEGIN
			UPDATE tp
			SET tp.VerDetalle=1
			FROM #TEMP_PROVEEDORES tp
				INNER JOIN dbo.MM_PeticionOferta po ON po.IdSubcontratista = tp.IdProveedor
				INNER JOIN dbo.MM_SolicitudPedido sp ON sp.IdSolicitudPedido = po.IdSolicitudPedido
			WHERE sp.IdProveedor = @IdProveedor2 AND po.Cotizado = 1
		END
		----------------------------------------case-------------------------------
	
    SELECT *
    FROM #TEMP_PROVEEDORES
	ORDER BY VerDetalle DESC, RazonSocial
	--WHERE VerDetalle = 1
	

    
END



