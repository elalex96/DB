-- =============================================
-- Author:		Alexander Gomez
-- Create date: 15/Jul/2019
-- Description:	se agrego la lista negra del sat
-- =============================================
-- Author:		Daniel AC
-- Create date: 14/01/2022
-- Description:	Optimizacion de SP 
-- =============================================

CREATE PROCEDURE [dbo].[SP_MM_ProveedoresPorMaterialCat]-- 0,420,0,0,0
    -- Add the parameters for the stored procedure here
    @IdMaterialMaestro INT,
	@IdProveedor2 INT, 
    @IdContrato INT,
    @IdUsuario INT,
    @FechaRegistro DATETIME

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
     CREATE TABLE #Giros (IdProveedor INT, Giro NVARCHAR(MAX))
	 CREATE TABLE #GirosConcat(IdProveedor INT, Giro NVARCHAR(MAX))
	 CREATE TABLE #EmailProveedor (IdProveedor INT, Email NVARCHAR(MAX))

    DECLARE @IDCONTRATISTA INT
							

	IF ISNULL(@IdContrato,0) = 0 			
	BEGIN

			SET @IDCONTRATISTA = (SELECT TOP 1 ci.IdContratista 
							FROM dbo.S_Proveedor AS pr (NOLOCK)
							LEFT JOIN Adinco.dbo.CO_Contratista AS ci  (NOLOCK)
								ON pr.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = ci.RFC COLLATE SQL_Latin1_General_CP1_CI_AS 
							WHERE pr.IdProveedor=@IdProveedor2)


			SET @IdContrato = (SELECT TOP 1 co.IdContrato 
								FROM adinco.dbo.CO_Contrato AS co (NOLOCK)
								WHERE co.IdContratista = @IDCONTRATISTA			
								)
	END

			                                       

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
               null,
               CPY.Nombre AS Clasificacion,
               '',
               P.Telefono,
               '' AS CorreoProveedor,
			   0,
			   CASE WHEN LN.RFC  IS NULL THEN 0 ELSE 1 END AS InBlackList
        FROM dbo.S_Proveedor AS P (NOLOCK)
            LEFT JOIN S_Nacionalidad n
                ON P.IdNacionalidad = n.IdNacionalidad
            LEFT JOIN MM_Material M (NOLOCK)
                ON P.IdProveedor = M.IdProveedor            
            LEFT JOIN dbo.PV_ClasificacionEmpresaProveedor AS CEP (NOLOCK)
                ON  P.IdProveedor = CEP.IdProveedor
            LEFT JOIN dbo.PV_ClasificacionPyMES AS CPY (NOLOCK)
                ON CEP.IdClasificacionEmpresa = CPY.IdClasificacion 
			LEFT JOIN Adinco.dbo.ListaNegra AS LN (NOLOCK)
				ON P.RFC COLLATE Modern_Spanish_CI_AS = LN.RFC COLLATE Modern_Spanish_CI_AS 
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
              null,
               CPY.Nombre AS Clasificacion,
               '',
               p.Telefono,
               '' AS CorreoProveedor,
			   0,
			   CASE WHEN LN.RFC  IS NULL THEN 0 ELSE 1 END AS InBlackList
        FROM Petrovendor.dbo.S_Proveedor p (NOLOCK)
            LEFT JOIN S_Nacionalidad n (NOLOCK)
                ON p.IdNacionalidad = n.IdNacionalidad
            LEFT JOIN dbo.PV_ClasificacionEmpresaProveedor AS CEP (NOLOCK)
                ON  p.IdProveedor = CEP.IdProveedor
            LEFT JOIN dbo.PV_ClasificacionPyMES AS CPY (NOLOCK)
                ON CEP.IdClasificacionEmpresa = CPY.IdClasificacion 
			LEFT JOIN Adinco.dbo.ListaNegra AS LN (NOLOCK)
				ON  P.RFC COLLATE Modern_Spanish_CI_AS = LN.RFC COLLATE Modern_Spanish_CI_AS 
        WHERE p.Activo = 1
              AND ISNULL(p.IsEliminado, 0) = 0
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
	  
	 /*Obtener giros de los proveedores*/
	 INSERT INTO #Giros(IdProveedor,Giro)
	 SELECT  P.IdProveedor, GE.GiroProveedor
     FROM #TEMP_PROVEEDORES P
		JOIN dbo.PV_PerfilGiroEmpresarial AS PGE  (NOLOCK)
			ON P.IdProveedor = PGE.IdProveedor
			AND PGE.Activo = 1
        JOIN dbo.PV_GiroEmpresarial AS GE (NOLOCK)
            ON PGE.IdGiroEmpresarial = GE.IdGiroProveedor   -- METODO PARA CONCATENAR LOS GIROS EMPRESARIALES POR PROVEEDOR
    ORDER BY GE.GiroProveedor ASC

	/*Agrupar giros por proveedor*/
     INSERT INTO    #GirosConcat(IdProveedor,Giro)
	 SELECT GE.IdProveedor,
	 STUFF(
    (SELECT ', '  + RTRIM(LTRIM(GI.Giro))
     FROM #Giros GI
     WHERE GI.IdProveedor= GE.IdProveedor
     FOR XML PATH('')),
     1, 2, '') As Giro
	 FROM #Giros GE
	 GROUP BY GE.IdProveedor

	 UPDATE temp
	 SET GiroProveedor =G.Giro
	 FROM  #TEMP_PROVEEDORES temp
	 JOIN #GirosConcat G
		ON temp.IdProveedor= G.IdProveedor

	 /*Obtener el primer contacto por proveedor*/
	 INSERT INTO #EmailProveedor(IdProveedor,Email)
	 SELECT IdProveedor,Correo FROM (
	 SELECT 
	 ROW_NUMBER() OVER(PARTITION BY P.IdProveedor ORDER BY  U.IdTipoUsuario DESC) AS r,
	 P.IdProveedor,
	 U.Correo
	 FROM #TEMP_PROVEEDORES P
	 JOIN	dbo.S_UsuarioProveedor uProv (NOLOCK)
			ON  P.IdProveedor = uProv.IdProveedor
	 JOIN  S_Usuario U (NOLOCK)
		ON uProv.IdUsuario = U.IdUsuario
	WHERE U.IdTipoUsuario IN ( 4, 3 ) --ventas o administrador
	AND U.Activo = 1
	AND ISNULL (U.IsEliminado, 0 ) = 0
	AND u.Correo <> ''
	GROUP BY P.IdProveedor,U.Correo,U.IdTipoUsuario) as r where r.r=1

	UPDATE temp
	 SET Email =EP.Email
	 FROM  #TEMP_PROVEEDORES temp
	 JOIN #EmailProveedor EP
		ON temp.IdProveedor= EP.IdProveedor


    UPDATE temp --- ACTUALIZAMOS CAMPOS
    SET Contacto = CONCAT(contacto.Nombres, ' ', contacto.Apellidos)
    FROM #TEMP_PROVEEDORES temp
        INNER JOIN dbo.S_Contacto contacto
            ON temp.IdProveedor = contacto.IdProveedor
    	
	---  Activación de Detalles ---
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
				INNER JOIN dbo.MM_PeticionOferta po (NOLOCK)
					ON tp.IdProveedor = po.IdSubcontratista 
				INNER JOIN dbo.MM_SolicitudPedido sp (NOLOCK)
					ON po.IdSolicitudPedido = sp.IdSolicitudPedido 
			WHERE sp.IdProveedor = @IdProveedor2 AND po.Cotizado = 1
		END
		----------------------------------------case-------------------------------
	
    SELECT *
    FROM #TEMP_PROVEEDORES
	ORDER BY VerDetalle DESC, RazonSocial

	    
END



