USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MPY_MM_CartaProveedor'
)
    DROP PROCEDURE SP_MPY_MM_CartaProveedor;

/****** Object:  StoredProcedure [dbo].[SP_PO_ConsultarProveedoresCotizacion]    Script Date: 20/09/2023 01:36:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  StoredProcedure [dbo].[SP_MPY_MM_CartaProveedor]    Script Date: 21/09/2023 09:33:47 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David De La Cruz
-- Create date: 07-09-2020
-- Description:	Fix bug issue 667 GitHub, ajuste en mostrar contrato
-- =============================================  
-- =============================================
-- Author:		David De La Cruz
-- Create date: 06-11-2020
-- Description:	Fix bug issue 801 GitHub, 18 meses a 5 años
-- ============================================= 
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 18-02-2021
-- Description:	adaptacion para carta PROVEEDOR A PROVEEDOR para DEA
-- =============================================  
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 12-07-2023
-- Description:	adaptacion para carta PROVEEDOR A PROVEEDOR para Amatitlan, se aplican estandares de desarrollo
-- ============================================= 
-- Author:		Alexander Gomez
-- Update: 19/07/2023
-- Description:	se agregan validaciones de configuraciones issue: https://github.com/Adinco/petrovendor/issues/2388
-- =============================================
-- Author:		Alexander Gomez
-- Update: 27/07/2023
-- Description:	se iguala el calculo de partidas a 3 decimales sin redondear issue: https://github.com/Adinco/petrovendor/issues/2397
-- =============================================
-- Author:	Daniel AC
-- Update: 31/07/2023
-- Description:	se agregan validaciones para evitar mostrar información de mercadeo cuando es murphy https://github.com/Adinco/petrovendor/issues/2407
-- =============================================
-- Author:	Alexander Gomez
-- Update: 19/09/2023
-- Description: se corrige el primero parrafo de carta de proveedor a proveedor https://github.com/Adinco/petrovendor/issues/2488
-- =============================================
-- =============================================
-- Author:	Daniel AC
-- Update: 21-09-2023
-- Description:	Se agrega mejora para personas fisicas de Pico, se vea CURP https://github.com/Adinco/petrovendor/issues/2493
-- =============================================
-- =============================================  
-- Author:  Alexander Gomez  
-- Create date: 07/07/2025
-- Description: Se actualiza texto en parrafo 3 https://github.com/Adinco/petrovendor/issues/3020
-- =============================================  
CREATE PROCEDURE [dbo].[SP_MPY_MM_CartaProveedor]   
 -- Add the parameters for the stored procedure here  
@IdProveedor INT,  
@IdPedido INT,  
@IdContrato INT = NULL,  
@IdUsuario INT = NULL,  
@fchRegistro DATETIME = NULL  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
    -- Insert statements for procedure here  

 DECLARE @IdTipoRegimen INT   
 Declare @NombreOperadora NVARCHAR(MAX)  
 Declare @VendorsName NVARCHAR(MAX)  
 DECLARE @RFC_ACTUAL_DEA NVARCHAR(200), 
		@EXISTE_RFC_DEA INT;
 DECLARE @TablaIdsRepresentanteLegal TABLE (IdRepresentante INT);
 DECLARE @UsuarioFisico NVARCHAR(MAX);
 DECLARE @NOMBRE_CONTRATO nvarchar(300);
 DECLARE @PROVEEDOR_DEA INT;
 DECLARE @CANT_TMAT INT;
 DECLARE @CANT_TSER INT;
 DECLARE @TIPO_MATERIAL NVARCHAR(MAX),
		@RFC_ACTUAL NVARCHAR(200), 
		@CONFIGURACION_CARTA NVARCHAR(100);
  
--> SI VIENE EN 0 ES UN PROVEEDOR DE MURPHY
 IF(@IdProveedor = 0)  
 BEGIN  
  SET @IdProveedor = (SELECT  
        MAX(PR.IdProveedor)  
       FROM dbo.S_Proveedor AS PR (NOLOCK)
		JOIN Adinco.dbo.CO_SAPVendor AS SV (NOLOCK) 
			ON PR.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = SV.TaxID COLLATE SQL_Latin1_General_CP1_CI_AS
       JOIN dbo.MPY_MM_AceptacionPedido AS AP (NOLOCK)
			ON SV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdSubContratista COLLATE SQL_Latin1_General_CP1_CI_AS 
       WHERE AP.IdAceptacionPedido = @IdPedido 
			AND PR.Activo = 1)  
 END;  
  
 SET @IdTipoRegimen =(SELECT IdTipoRegimen 
					 FROM S_PROVEEDOR (NOLOCK) 
					 WHERE IdProveedor = @IdProveedor);

 IF (@IdTipoRegimen = 2)  --> CTE PERSONA FISICA --> S_TipoRegimen
 BEGIN  
  SELECT 
		TOP 1 
		@UsuarioFisico = U.Nombre -->  RepresentanteLegal 	
	FROM S_Proveedor AS P (NOLOCK)
		JOIN S_UsuarioProveedor UP (NOLOCK)
			ON P.IdProveedor = UP.IdProveedor  
		JOIN S_Usuario U (NOLOCK)
			ON UP.IdUsuario = U.IdUsuario
				AND U.Activo = 1 --> CTE USUARIO ACTIVO
				AND ISNULL(U.IsEliminado,0) = 0 --> CTE NO ESTE ELIMINADO
		WHERE U.IdTipoUsuario = 3 --> USUARIO TIPO ADMINISTRADOR
				AND P.IdProveedor = @IdProveedor;
  
 END  
  
 SET @NombreOperadora = (SELECT 
							ISNULL(CONCAT(RazonSocial, ' '),A.IdProveedor) AS Proveedor  
						FROM S_Proveedor AS P  (NOLOCK)
						INNER JOIN MPY_MM_AceptacionPedido AS A (NOLOCK)
							ON P.RFC = A.IdProveedor
								AND P.Activo = 1  
						WHERE A.IdAceptacionPedido = @IdPedido);
  
 SET @VendorsName = (SELECT 
							A.VendorsName  
					   FROM MPY_MM_AceptacionPedido AS A (NOLOCK)
					   WHERE A.IdAceptacionPedido = @IdPedido)  
  
  
 SET @NOMBRE_CONTRATO = (SELECT 
												CO.NumeroContrato  
											FROM adinco.dbo.CO_Contrato AS CO (NOLOCK)
											JOIN dbo.MPY_MM_AceptacionPedido AS AP (NOLOCK)
												ON CO.IdContrato = AP.IdContrato  
											WHERE AP.IdAceptacionPedido = @IdPedido);  
  
SET @PROVEEDOR_DEA = 0; 
  
  
 SET @CANT_TMAT = (SELECT 
								COUNT(VP.IdTipoMaterialServicio)  
							FROM dbo.MPY_MM_PCN_ValoresPesos AS VP (NOLOCK)
								LEFT JOIN dbo.MPY_MM_AceptacionPedidoDetalle AS APD (NOLOCK)
									ON VP.IdAceptacionPedidoDetalle  = APD.IdAceptacionPedidoDetalle 
								LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP (NOLOCK)
									ON APD.IdAceptacionPedido = AP.IdAceptacionPedido 
							WHERE AP.IdAceptacionPedido = @IdPedido 
								AND VP.IdTipoMaterialServicio = 1); --> 1 CTE MATERIAL
  
 SET @CANT_TSER = (SELECT 
								COUNT(VP.IdTipoMaterialServicio)  
							FROM dbo.MPY_MM_PCN_ValoresPesos AS VP (NOLOCK)
							LEFT JOIN dbo.MPY_MM_AceptacionPedidoDetalle AS APD (NOLOCK)
								ON VP.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle  
							LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP (NOLOCK)
								ON APD.IdAceptacionPedido  = AP.IdAceptacionPedido
							WHERE AP.IdAceptacionPedido = @IdPedido 
								AND VP.IdTipoMaterialServicio = 2); --> CTE SERVICIO
  
 SET @TIPO_MATERIAL = 'Material/Servicio';  
  
 IF @CANT_TMAT > 0 AND @CANT_TSER = 0  
 BEGIN  
  SET @TIPO_MATERIAL = 'Materiales';  
 END  
  
 IF @CANT_TMAT = 0 AND @CANT_TSER > 0  
 BEGIN  
  SET @TIPO_MATERIAL = 'Servicios';  
 END  
  
 IF @CANT_TMAT > 0 AND @CANT_TSER > 0  
 BEGIN  
  SET @TIPO_MATERIAL = 'Materiales/Servicios';  
 END  
  
 IF @IdContrato = 10053--CONTRATO EL DORADO  
BEGIN   
  
  
 IF (@IdTipoRegimen = 2)  
 BEGIN  
    SET LANGUAGE spanish;  
    SELECT DISTINCT TOP 1  
    DAY ( GETDATE ()) AS DIA, DATENAME ( MONTH, DATEADD ( MONTH, MONTH ( GETDATE ()), -1 )) AS MES ,  
    RIGHT(CAST(YEAR ( GETDATE ()) AS CHAR(4)), 2) AS ANIO ,  
    'Ciudad de México, al ' + CAST(DAY ( GETDATE ()) AS NVARCHAR(2)) + ' de '  
    + CAST(DATENAME ( MONTH, DATEADD ( MONTH, MONTH ( GETDATE ()), -1 )) AS NVARCHAR(10)) + ' del '  
    + CONVERT ( NVARCHAR(10), YEAR ( GETDATE ())) AS FECHA,  
    CON.RazonSocial AS NombreOperadora,   
    @UsuarioFisico AS RepresentanteLegal,   
        'CARTA DE PROVEEDOR A PROVEEDOR DE LO DESTINADO A UNA ASIGNACIÓN, CONTRATO O PERMISO, DE LA INDUSTRIA DE HIDROCARBUROS' AS Titulo,  
        'Por medio de la presente, el (la) que suscribe ' + @UsuarioFisico  
        +' representante legal de la empresa ' + ISNULL(P.RazonSocial,SV.VendorName)  
        + case when isnull(AC.NoActaConstitutiva,'') <> '' then  ' lo que acredito con el instrumento público número ' + CAST(AC.NoActaConstitutiva AS NVARCHAR(MAX))  
				else '' end
		+ ', DECLARO BAJO PROTESTA DE DECIR VERDAD, que el (los) ' + @TIPO_MATERIAL   
        +' declarado(s) a continuación, se suministraron y facturaron al Operador del (de la) ' + @NOMBRE_CONTRATO + ' en el año '
        + CAST(Year(GETDATE()) AS NVARCHAR(50)) + ' cuenta(n) con la Proporción de Contenido Nacional que se señala en esta carta'  
        + ' y que mi representada la obtuvo de conformidad con lo establecido en el “Acuerdo por el '  
        + 'que se establece la Metodología para la Medición del Contenido Nacional en Asignaciones y '  
        + 'Contratos para la Exploración y Extracción de Hidrocarburos, así como para los permisos en '  
        + 'la Industria de Hidrocarburos”, y demás disposiciones jurídicas aplicables, es correcta, completa,'  
        +' veraz y verificable.' AS PrimerInical,  
        '1. Los datos asentados en la presente carta pueden ser verificados por la Secretaría de Economía, por lo que, en caso de requerirlo, mi representada debe poner a disposición de la referida autoridad el soporte documental de lo declarado, en la forma que establezcan las disposiciones jurídicas aplicables.' AS PrimerParafo,  
        '2. Que está obligada a conservar el soporte documental de la información declarada en esta carta, por lo menos 5 años contados a partir del mes de abril del año siguiente a aquél en que la entregue, y en caso de que se notifique al Operador (Asignatario, Contratista o Permisionario) que se va a verificar la información que haya reportado de contenido nacional, deberá conservar el soporte documental hasta que concluya la verificación; y que cuando se promueva algún recurso o juicio relacionado con la entrega de información o de su verificación, el plazo para conservar la información de contenido nacional, se computará a partir de la fecha en la que quede firme la resolución que le ponga fin al juicio o recurso, por lo que mi representada estará al tanto con el cliente al que dirige esta Carta.' AS SegundoParrafo,  
        '3. Las sanciones a que se puede hacer acreedora, por incumplir o entorpecer la obligación de informar el contenido nacional, conforme a las disposiciones jurídicas aplicables, incluido lo dispuesto en Título Cuarto, Capítulo I de la Ley de Hidrocarburos, en particular lo previsto en los artículos 120, fracción II y 121, fracción III. ' AS TercerParrafo,  
        'Lo anterior, de conformidad con lo dispuesto en el artículo 74, párrafo quinto de la Ley de Hidrocarburos, los puntos 15, párrafos segundo y tercero del Acuerdo por el que se establecen las disposiciones para que los Asignatarios, Contratistas y Permisionarios proporcionen información sobre contenido nacional en las actividades que realicen en la Industria de Hidrocarburos (el Acuerdo) y demás disposiciones jurídicas aplicables.' AS CuartoParrafo,  
        'Finalmente, se señala como domicilio para oír y recibir notificaciones relacionadas con lo dispuesto en el Acuerdo y demás disposiciones jurídicas aplicables, el ubicado en '  
        + CONCAT (  
        domicilio.TipoViabilidad, ' ', domicilio.Calle, CASE WHEN domicilio.NoExterior = '' THEN  
                       ''  
                    ELSE  
                     ', No. Exterior ' + domicilio.NoExterior  
                    END ,  
        CASE WHEN domicilio.NoInterior = '' THEN  
           ''  
        ELSE  
         ', No. Interior ' + domicilio.NoInterior  
        END, CASE WHEN domicilio.Colonia = '' THEN  
             ''  
          ELSE  
           ' Col. ' + domicilio.Colonia  
          END, CASE WHEN domicilio.Municipio = '' THEN  
               ''  
            ELSE  
             ', ' + domicilio.Municipio  
            END, ' ', domicilio.Estado, ' ', domicilio.Pais ,  
        CASE WHEN domicilio.CodigoPostal = '' THEN  
           ''  
        ELSE  
         ', C.P. ' + domicilio.CodigoPostal  
        END, CASE WHEN U.Correo = '' THEN  
             ''  
          ELSE  
           ', Correo Electrónico Contacto: ' + U.Correo  
          END, CASE WHEN P.Telefono = '' THEN '' ELSE ', Tel. ' + P.Telefono END )  
        + '. En caso de que este domicilio cambie, me comprometo a informárselo inmediatamente.' AS QuintoParrafo  
    FROM dbo.MPY_MM_AceptacionPedido AS AP (NOLOCK)
		LEFT JOIN S_Proveedor AS P (NOLOCK)
			ON P.IdProveedor = @IdProveedor 
			AND P.Activo = 1  
		LEFT JOIN DG_RepresentanteLegal RL (NOLOCK) 
			ON P.IdProveedor = RL.IdProveedor
			AND RL.IsActivo =1  
		LEFT JOIN DG_ActaConstitutiva AC (NOLOCK) 
			ON P.IdProveedor  = AC.IdProveedor
				AND AC.IsActivo = 1  
		LEFT JOIN S_UsuarioProveedor UP (NOLOCK) 
			ON P.IdProveedor = UP.IdProveedor  
		LEFT JOIN S_Usuario U (NOLOCK) 
			ON UP.IdUsuario = U.IdUsuario   
			AND U.Activo = 1
			AND ISNULL(U.IsEliminado,0) = 0
		LEFT JOIN Adinco.dbo.CO_SAPPO AS PO (NOLOCK) 
			ON AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS  = PO.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS 
		LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS CP	(NOLOCK) 
			ON PO.Plant = CP.Planta 
		LEFT JOIN Adinco.dbo.CO_Contratista AS CON (NOLOCK) 
			ON CP.IdContratista = CON.IdContratista  
		LEFT JOIN Adinco.dbo.CO_Contratista AS C (NOLOCK) 
			ON CAST(AP.IdProveedor AS INT) = C.IdContratista
		LEFT JOIN Adinco.dbo.CO_SAPVendor SV (NOLOCK) 
			ON AP.IdSubContratista COLLATE SQL_Latin1_General_CP1_CI_AS = SV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS  
		LEFT JOIN dbo.DG_Domicilio domicilio (NOLOCK) 
			ON P.IdProveedor = domicilio.IdProveedor 
			AND domicilio.IdTipoDomicilio = 1 
			AND domicilio.Activo = 1  
    WHERE AP.IdAceptacionPedido= @IdPedido  
    GROUP BY P.RazonSocial,
			P.RegimenCapital,
			RL.Nombre,
			RL.APaterno,
			RL.AMaterno,
			AC.Nombre, 
			SV.VendorName,
			CON.RazonSocial,  
			P.CURP, 
			domicilio.TipoViabilidad,
			domicilio.NombreViabilidad,
			domicilio.NoExterior,
			domicilio.NoInterior,
			domicilio.Colonia,
			domicilio.Municipio,
			domicilio.Estado, 
			domicilio.Pais,
			domicilio.CodigoPostal,
			P.CorreoProveedor,
			P.Telefono,
			domicilio.Calle,
			U.Correo,
			AP.IdSubContratista,
			AC.NoActaConstitutiva;

  END  
  ELSE  
  BEGIN  
  SET LANGUAGE spanish;  
  SELECT DISTINCT TOP 1  
  DAY ( GETDATE ()) AS DIA, DATENAME ( MONTH, DATEADD ( MONTH, MONTH ( GETDATE ()), -1 )) AS MES ,  
       RIGHT(CAST(YEAR ( GETDATE ()) AS CHAR(4)), 2) AS ANIO ,  
       'Ciudad de México, al ' + CAST(DAY ( GETDATE ()) AS NVARCHAR(2)) + ' de '  
       + CAST(DATENAME ( MONTH, DATEADD ( MONTH, MONTH ( GETDATE ()), -1 )) AS NVARCHAR(10)) + ' del '  
       + CONVERT ( NVARCHAR(10), YEAR ( GETDATE ())) AS FECHA,  
    CON.RazonSocial AS NombreOperadora,   
    CONCAT(RL.Nombre,' ',RL.APaterno,' ',RL.AMaterno) AS RepresentanteLegal,   
        'CARTA DE PROVEEDOR A PROVEEDOR DE LO DESTINADO A UNA ASIGNACIÓN, CONTRATO O PERMISO, DE LA INDUSTRIA DE HIDROCARBUROS' AS Titulo,  
        'Por medio de la presente, el (la) que suscribe ' + CONCAT(RL.Nombre,' ',RL.APaterno,' ',RL.AMaterno)  
        +' representante legal de la empresa ' + ISNULL(P.RazonSocial,SV.VendorName)  
        + ' lo que acredito con el instrumento público número ' + CAST(AC.NoActaConstitutiva AS NVARCHAR(MAX))  
        + ', DECLARO BAJO PROTESTA DE DECIR VERDAD, que el (los) ' + @TIPO_MATERIAL   
        +' declarado(s) a continuación, se suministraron y facturaron al Operador del (de la) ' + @NOMBRE_CONTRATO + ' en el año '
        + CAST(Year(GETDATE()) AS NVARCHAR(50)) + ' cuenta(n) con la Proporción de Contenido Nacional que se señala en esta carta'  
        + ' y que mi representada la obtuvo de conformidad con lo establecido en el “Acuerdo por el '  
        + 'que se establece la Metodología para la Medición del Contenido Nacional en Asignaciones y '  
        + 'Contratos para la Exploración y Extracción de Hidrocarburos, así como para los permisos en '  
        + 'la Industria de Hidrocarburos”, y demás disposiciones jurídicas aplicables, es correcta, completa,'  
        +' veraz y verificable.' AS PrimerInical,  
        '1. Los datos asentados en la presente carta pueden ser verificados por la Secretaría de Economía, por lo que, en caso de requerirlo, mi representada debe poner a disposición de la referida autoridad el soporte documental de lo declarado, en la forma que establezcan las disposiciones jurídicas aplicables.' AS PrimerParafo,  
        '2. Que está obligada a conservar el soporte documental de la información declarada en esta carta, por lo menos 5 años contados a partir del mes de abril del año siguiente a aquél en que la entregue, y en caso de que se notifique al Operador (Asignatario, Contratista o Permisionario) que se va a verificar la información que haya reportado de contenido nacional, deberá conservar el soporte documental hasta que concluya la verificación; y que cuando se promueva algún recurso o juicio relacionado con la entrega de información o de su verificación, el plazo para conservar la información de contenido nacional, se computará a partir de la fecha en la que quede firme la resolución que le ponga fin al juicio o recurso, por lo que mi representada estará al tanto con el cliente al que dirige esta Carta.' AS SegundoParrafo,  
        '3. Las sanciones a que se puede hacer acreedora, por incumplir o entorpecer la obligación de informar el contenido nacional, conforme a las disposiciones jurídicas aplicables, incluido lo dispuesto en Título Cuarto, Capítulo I de la Ley de Hidrocarburos, en particular lo previsto en los artículos 120, fracción II y 121, fracción III. ' AS TercerParrafo,  
        'Lo anterior, de conformidad con lo dispuesto en el artículo 74, párrafo quinto de la Ley de Hidrocarburos, los puntos 15, párrafos segundo y tercero del Acuerdo por el que se establecen las disposiciones para que los Asignatarios, Contratistas y Permisionarios proporcionen información sobre contenido nacional en las actividades que realicen en la Industria de Hidrocarburos (el Acuerdo) y demás disposiciones jurídicas aplicables.' AS CuartoParrafo,  
        'Finalmente, se señala como domicilio para oír y recibir notificaciones relacionadas con lo dispuesto en el Acuerdo y demás disposiciones jurídicas aplicables, el ubicado en '  
        + CONCAT (  
        domicilio.TipoViabilidad, ' ', domicilio.Calle, CASE WHEN domicilio.NoExterior = '' THEN  
                       ''  
                    ELSE  
                     ', No. Exterior ' + domicilio.NoExterior  
                    END ,  
        CASE WHEN domicilio.NoInterior = '' THEN  
           ''  
        ELSE  
         ', No. Interior ' + domicilio.NoInterior  
        END, CASE WHEN domicilio.Colonia = '' THEN  
             ''  
          ELSE  
           ' Col. ' + domicilio.Colonia  
          END, CASE WHEN domicilio.Municipio = '' THEN  
               ''  
            ELSE  
             ', ' + domicilio.Municipio  
            END, ' ', domicilio.Estado, ' ', domicilio.Pais ,  
        CASE WHEN domicilio.CodigoPostal = '' THEN  
           ''  
        ELSE  
         ', C.P. ' + domicilio.CodigoPostal  
        END, CASE WHEN U.Correo = '' THEN  
             ''  
          ELSE  
           ', Correo Electrónico Contacto: ' + U.Correo  
          END, CASE WHEN P.Telefono = '' THEN '' ELSE ', Tel. ' + P.Telefono END )  
        + '. En caso de que este domicilio cambie, me comprometo a informárselo inmediatamente.' AS QuintoParrafo  
    FROM dbo.MPY_MM_AceptacionPedido AS AP (NOLOCK)
		LEFT JOIN S_Proveedor AS P 
			ON P.IdProveedor = @IdProveedor 
				AND P.Activo = 1  
		LEFT JOIN DG_RepresentanteLegal RL (NOLOCK) 
			ON RL.IdProveedor = @IdProveedor 
				AND RL.IsActivo =1  
		LEFT JOIN DG_ActaConstitutiva AC (NOLOCK)
			ON AC.IdProveedor = @IdProveedor AND AC.IsActivo = 1  
		LEFT JOIN S_UsuarioProveedor UP (NOLOCK)
			ON P.IdProveedor = UP.IdProveedor  
		LEFT JOIN S_Usuario U (NOLOCK) 
			ON UP.IdUsuario = U.IdUsuario  
				AND U.Activo = 1
				AND ISNULL(U.IsEliminado,0) = 0
		LEFT JOIN Adinco.dbo.CO_SAPPO AS PO (NOLOCK)
			ON AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS = PO.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS  
		LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS CP (NOLOCK)
			ON PO.Plant  = CP.Planta
		LEFT JOIN Adinco.dbo.CO_Contratista AS CON (NOLOCK)
			ON CP.IdContratista = CON.IdContratista  
		LEFT JOIN Adinco.dbo.CO_Contratista AS C (NOLOCK)
			ON CAST(AP.IdProveedor AS INT)  = C.IdContratista 
		LEFT JOIN Adinco.dbo.CO_SAPVendor SV (NOLOCK)
			ON AP.IdSubContratista COLLATE SQL_Latin1_General_CP1_CI_AS = SV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS  
		LEFT JOIN dbo.DG_Domicilio domicilio (NOLOCK)
			ON P.IdProveedor = domicilio.IdProveedor 
				AND domicilio.IdTipoDomicilio = 1 AND domicilio.Activo = 1  
    WHERE AP.IdAceptacionPedido = @IdPedido   
    GROUP BY RL.Nombre,  
			 RL.APaterno,  
			 RL.AMaterno,  
			 AC.Nombre,   
			 AC.NoActaConstitutiva,  
			 AP.IdProveedor,  
			 AP.IdDomicilioEntrega,  
			 AP.IdSubContratista,  
			 P.RazonSocial,  
			 SV.VendorName,  
			 CON.RazonSocial,  
			 domicilio.TipoViabilidad,  
			 domicilio.Calle,  
			 domicilio.NoExterior,  
			 domicilio.NoInterior,  
			 domicilio.Colonia,  
			 domicilio.Municipio,  
			 domicilio.Estado,  
			 domicilio.Pais,  
			 domicilio.CodigoPostal,  
			 U.Correo,  
			 P.Telefono,  
			 C.NombreContratista;  
 
  END;  
  END;  
ELSE  
BEGIN  
	--> ES FUNCIONALIDAD PARA OPERADORAS CON CONFIGURACIÓN DE CARTA PROVEEDOR A PROVEEDOR 
	set @RFC_ACTUAL_DEA = (SELECT TOP 1
							P.RFC
						FROM dbo.MM_AceptacionPedido AS AP (NOLOCK)
						JOIN dbo.S_Proveedor AS P (NOLOCK)
							ON AP.IdProveedor  = P.IdProveedor
						WHERE AP.IdAceptacionPedido = @IdPedido);

	set @EXISTE_RFC_DEA = (SELECT COUNT(IdProveedor) 
							FROM DEA_Proveedor (NOLOCK)
							WHERE RTRIM(LTRIM(RFC))=RTRIM(LTRIM(@RFC_ACTUAL_DEA)) 
							AND Activo = 1);

	SELECT TOP 1
		@RFC_ACTUAL = P.RFC,
		@IdContrato = PD.IdContrato
	FROM dbo.MM_AceptacionPedido AS AP (NOLOCK)
		JOIN dbo.S_Proveedor AS P (NOLOCK) 
			ON AP.IdProveedor = P.IdProveedor
		JOIN MM_Pedido AS PD (NOLOCK) 
			ON AP.IdPedido = PD.IdPedido
	WHERE AP.IdAceptacionPedido = @IdPedido
	AND PD.IdSubcontratista = @IdProveedor;

	--SE VERIFICA EL RFC ESTE EN LA CONFIGURACION
	SET @CONFIGURACION_CARTA = (SELECT
									TipoConfiguracion
								FROM PV_ConfiguracionProveedoresOperadoras (NOLOCK)
								WHERE IdContrato = @IdContrato
									AND TipoConfiguracion = 'CARTA_PR_PR'
									AND Operadora = 1 --> CTE
									AND Activo = 1);--> CTE ESTE ACTIVA LA CONFIGURACIÓN

  IF  @EXISTE_RFC_DEA > 0 OR @CONFIGURACION_CARTA = 'CARTA_PR_PR'
  BEGIN
  -- > CARTA PARA FUNCIONALIDAD DE PROVEEDOR A PROVEEDOR MENDIANTE LA CONFIRACIÓN DE CONSOLA CARTA_PR_PR

	SET @CANT_TMAT = (SELECT COUNT(VP.IdTipoMaterialServicio)  
					FROM dbo.MM_PCN_ValoresPesos AS VP (NOLOCK) 
					LEFT JOIN dbo.MM_AceptacionPedidoDetalle AS APD 
						ON VP.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle  
					LEFT JOIN dbo.MM_AceptacionPedido AS AP (NOLOCK)
						ON APD.IdAceptacionPedido  = AP.IdAceptacionPedido
					WHERE AP.IdAceptacionPedido = @IdPedido 
						AND VP.IdTipoMaterialServicio = 1); --> CTE MATERIALES
  
	SET @CANT_TSER = (SELECT 
						COUNT(VP.IdTipoMaterialServicio)  
					FROM dbo.MM_PCN_ValoresPesos AS VP  (NOLOCK)
					LEFT JOIN dbo.MM_AceptacionPedidoDetalle AS APD (NOLOCK)
						ON VP.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle  
					LEFT JOIN dbo.MM_AceptacionPedido AS AP (NOLOCK)
						ON APD.IdAceptacionPedido  = AP.IdAceptacionPedido 
					WHERE AP.IdAceptacionPedido = @IdPedido 
						AND VP.IdTipoMaterialServicio = 2); --> CTE SERVICIOS

	IF @CANT_TMAT > 0 AND @CANT_TSER = 0  
	 BEGIN  
	  SET @TIPO_MATERIAL = 'Materiales';  
	 END  
  
	 IF @CANT_TMAT = 0 AND @CANT_TSER > 0  
	 BEGIN  
	  SET @TIPO_MATERIAL = 'Servicios';  
	 END  
  
	 IF @CANT_TMAT > 0 AND @CANT_TSER > 0  
	 BEGIN  
	  SET @TIPO_MATERIAL = 'Materiales/Servicios';  
	 END  

	    SELECT @UsuarioFisico
            = (SELECT  TOP 1 
					CONCAT(ISNULL(legal.Nombre,''), ' ', ISNULL(legal.APaterno,''), ' ', ISNULL(legal.AMaterno,''))
               FROM dbo.DG_RepresentanteLegal legal (NOLOCK)
				WHERE IdProveedor = @IdProveedor
					AND IsActivo = 1
					AND ISNULL(IsEliminado,0) = 0
				ORDER BY CreadoEn DESC);
		
		IF ISNULL(@UsuarioFisico,'') = ''
			SET @UsuarioFisico = '-- INFORMACIÓN DE REPRESENTANTE LEGAL INCOMPLETA --'

		SET LANGUAGE spanish;  
		SELECT DISTINCT TOP 1  
			DAY ( GETDATE ()) AS DIA, DATENAME ( MONTH, DATEADD ( MONTH, MONTH ( GETDATE ()), -1 )) AS MES ,  
			RIGHT(CAST(YEAR ( GETDATE ()) AS CHAR(4)), 2) AS ANIO ,  
		    'Ciudad de México, al ' + CAST(DAY ( GETDATE ()) AS NVARCHAR(2)) + ' de ' + CAST(DATENAME ( MONTH, DATEADD ( MONTH, MONTH ( GETDATE ()), -1 )) AS NVARCHAR(10)) + ' del '  + CONVERT ( NVARCHAR(10), YEAR ( GETDATE ())) AS FECHA,  
			POP.RazonSocial AS NombreOperadora,   
			@UsuarioFisico AS RepresentanteLegal, 			 
			'CARTA DE PROVEEDOR A PROVEEDOR DE LO DESTINADO A UNA ASIGNACIÓN, CONTRATO O PERMISO, DE LA INDUSTRIA DE HIDROCARBUROS' AS Titulo,  
			CASE WHEN P.IdTipoRegimen = 1 THEN --> PERSONA MORAL
			'Por medio de la presente, el (la) que suscribe ' + @UsuarioFisico  
			+', representante legal de la empresa ' + ISNULL(P.RazonSocial,'')  
			+ case when ISNULL(AC.NoActaConstitutiva,'') <> '' then  ', lo que acredito con el instrumento público número ' + CAST(AC.NoActaConstitutiva AS NVARCHAR(MAX))  
					else '' end
			+ ', DECLARO BAJO PROTESTA DE DECIR VERDAD, que el (los) ' + @TIPO_MATERIAL 
			+ ' declarado(s) a continuación, que fueron facturados por mi representada, en el año '
			+ CAST(Year(GETDATE()) AS NVARCHAR(50)) + ', cuenta(n) con la Proporción de Contenido Nacional que se señala en esta carta'  
			+ ' y que mi representada la obtuvo de conformidad con lo establecido en el “Acuerdo por el '  
			+ 'que se establece la Metodología para la Medición del Contenido Nacional en Asignaciones y '  
			+ 'Contratos para la Exploración y Extracción de Hidrocarburos, así como para los permisos en '  
			+ 'la Industria de Hidrocarburos”, y demás disposiciones jurídicas aplicables, es correcta, completa,'  
			+' veraz y verificable.' 
			WHEN P.IdTipoRegimen = 2 THEN --> PERSONA FISICA 
			CONCAT('Por medio de la presente, el (la) que suscribe ',ISNULL(P.RazonSocial,'--RAZÓN SOCIAL INCOMPLETO--'),', BAJO MI PROPIO CONDUCTO, con Clave Única de Registro Poblacional CURP: ',ISNULL(P.CURP,'--CURP INCOMPLETO--'),', DECLARO BAJO PROTESTA DE DECIR VERDAD, que el (los) ',@TIPO_MATERIAL,' declarado(s) a continuación, que le fueron facturados por mi representada, en el año ',CAST(Year(GETDATE()) AS NVARCHAR(50)),', cuenta(n) con la Proporción de Contenido Nacional que se señala en esta carta, y que mi representada la obtuvo de conformidad con lo establecido en el "Acuerdo por el que se establece la Metodología para la Medición del Contenido Nacional en Asignaciones y Contratos para la Exploración y Extracción de Hidrocarburos, así como para los permisos en la Industria de Hidrocarburos", y demás disposiciones jurídicas aplicables, es correcta, completa, veraz y verificable.')
			ELSE 
			'--PROVEEDOR SIN TIPO DE REGIMEN ASIGNADO--'
			END AS PrimerInical,  
			'1. Los datos asentados en la presente carta pueden ser verificados por la Secretaría de Economía, por lo que, en caso de requerirlo, mi representada debe poner a disposición de la referida autoridad el soporte documental de lo declarado, en la forma que establezcan las disposiciones jurídicas aplicables.' AS PrimerParafo,  
			'2. Que está obligada a conservar el soporte documental de la información declarada en esta carta, por lo menos 5 años contados a partir del mes de abril del año siguiente a aquél en que la entregue, y en caso de que se notifique al Operador (Asignatario, Contratista o Permisionario) que se va a verificar la información que haya reportado de contenido nacional, deberá conservar el soporte documental hasta que concluya la verificación; y que cuando se promueva algún recurso o juicio relacionado con la entrega de información o de su verificación, el plazo para conservar la información de contenido nacional, se computará a partir de la fecha en la que quede firme la resolución que le ponga fin al juicio o recurso, por lo que mi representada estará al tanto con el cliente al que dirige esta Carta.' AS SegundoParrafo,  
			'3. Las sanciones a que se puede hacer acreedora, por incumplir o entorpecer la obligación de informar el contenido nacional, conforme a las disposiciones jurídicas aplicables, incluido lo dispuesto en Título Cuarto, Capítulo I de la Ley de Hidrocarburos, en particular lo previsto en los artículos 120, fracción II y 121, fracción III. ' AS TercerParrafo,  
			'Lo anterior, de conformidad con lo dispuesto en el artículo 74, párrafo quinto de la Ley de Hidrocarburos, los puntos 15, párrafos segundo y tercero del Acuerdo por el que se establecen las disposiciones para que los Asignatarios, Contratistas y Permisionarios proporcionen información sobre contenido nacional en las actividades que realicen en la Industria de Hidrocarburos (el Acuerdo) y demás disposiciones jurídicas aplicables.' AS CuartoParrafo,  
			'Finalmente, se señala como domicilio para oír y recibir notificaciones relacionadas con lo dispuesto en el Acuerdo y demás disposiciones jurídicas aplicables, el ubicado en '  
			+ CONCAT (  
			domicilio.TipoViabilidad, ' ', domicilio.Calle, CASE WHEN domicilio.NoExterior = '' THEN  
						   ''  
						ELSE  
						 ', No. Exterior ' + domicilio.NoExterior  
						END ,  
			CASE WHEN domicilio.NoInterior = '' THEN  
			   ''  
			ELSE  
			 ', No. Interior ' + domicilio.NoInterior  
			END, CASE WHEN domicilio.Colonia = '' THEN  
				 ''  
			  ELSE  
			   ' Col. ' + domicilio.Colonia  
			  END, CASE WHEN domicilio.Municipio = '' THEN  
				   ''  
				ELSE  
				 ', ' + domicilio.Municipio  
				END, ' ', domicilio.Estado, ' ', ISNULL(Pais.pais,'') ,  
			CASE WHEN domicilio.CodigoPostal = '' THEN  
			   ''  
			ELSE  
			 ', C.P. ' + domicilio.CodigoPostal  
			END, CASE WHEN U.Correo = '' THEN  
				 ''  
			  ELSE  
			   ', Correo Electrónico Contacto: ' + U.Correo  
			  END, CASE WHEN P.Telefono = '' THEN '' ELSE ', Tel. ' + P.Telefono END )  
			+ '. En caso de que este domicilio cambie, me comprometo a informárselo inmediatamente.' AS QuintoParrafo  
		FROM dbo.MM_AceptacionPedido AS AP  (NOLOCK)
			LEFT JOIN S_Proveedor AS P (NOLOCK)
				ON P.IdProveedor = @IdProveedor 
					AND P.Activo = 1  		
			LEFT JOIN DG_ActaConstitutiva AC (NOLOCK)
				ON P.IdProveedor = AC.IdProveedor 
				AND AC.IsActivo = 1  
			LEFT JOIN S_UsuarioProveedor UP (NOLOCK)
				ON P.IdProveedor = UP.IdProveedor  
			LEFT JOIN S_Usuario U (NOLOCK)
				ON UP.IdUsuario = U.IdUsuario 
					AND U.Activo = 1
					AND ISNULL(U.IsEliminado,0) = 0
			LEFT JOIN dbo.MM_Pedido AS PE (NOLOCK)
				ON AP.IdPedido = PE.IdPedido
			LEFT JOIN S_Proveedor AS POP (NOLOCK)
				ON PE.IdProveedorCompras = POP.IdProveedor
			LEFT JOIN Adinco.dbo.CO_Contrato AS CON (NOLOCK)
				ON PE.IdContrato = CON.IdContrato
			LEFT JOIN dbo.DG_Domicilio domicilio (NOLOCK)
				ON P.IdProveedor = domicilio.IdProveedor 
					AND domicilio.IdTipoDomicilio = 1 --> CTE DOMICILIO FISCAL
					AND domicilio.Activo = 1  --> CTE ESTE ACTIVO EL DOMICILIO
			LEFT JOIN PV_PaisRepublica Pais
			on domicilio.IdPais = Pais.id
		WHERE AP.IdAceptacionPedido= @IdPedido
		GROUP BY P.RazonSocial,
				P.RegimenCapital,
				P.IdTipoRegimen,				
				AC.Nombre, 
				P.CURP, 
				domicilio.TipoViabilidad,
				domicilio.NombreViabilidad,
				domicilio.NoExterior,
				domicilio.NoInterior,
				domicilio.Colonia,
				domicilio.Municipio,
				domicilio.Estado, 				
				domicilio.CodigoPostal,
				P.CorreoProveedor,
				P.Telefono,
				domicilio.Calle,
				U.Correo,
				AC.NoActaConstitutiva,
				POP.RazonSocial,
				CON.NumeroContrato,
				Pais.pais;

  END
  ELSE
  BEGIN
	
	IF (@IdTipoRegimen = 2)  
	BEGIN  
    SET LANGUAGE spanish;  
    SELECT DISTINCT TOP 1  
    DAY ( GETDATE ()) AS DIA, DATENAME ( MONTH, DATEADD ( MONTH, MONTH ( GETDATE ()), -1 )) AS MES ,  
       RIGHT(CAST(YEAR ( GETDATE ()) AS CHAR(4)), 2) AS ANIO ,  
       'Ciudad de México, al ' + CAST(DAY ( GETDATE ()) AS NVARCHAR(2)) + ' de '  
       + CAST(DATENAME ( MONTH, DATEADD ( MONTH, MONTH ( GETDATE ()), -1 )) AS NVARCHAR(10)) + ' del '  
       + CONVERT ( NVARCHAR(10), YEAR ( GETDATE ())) AS FECHA,  
    CON.RazonSocial AS NombreOperadora,   
    @UsuarioFisico AS RepresentanteLegal,   
        'CARTA DEL PROVEEDOR DIRECTO DEL OPERADOR' AS Titulo,  
        'Por medio de la presente, el (la) que suscribe ' + @UsuarioFisico  
        +' representante legal de la empresa ' + ISNULL(P.RazonSocial,SV.VendorName)  
       
		
		 + case when isnull(AC.NoActaConstitutiva,'') <> '' then  ' lo que acredito con el instrumento público número ' + CAST(AC.NoActaConstitutiva AS NVARCHAR(MAX))  
				else '' end
		  
        + ', DECLARO BAJO PROTESTA DE DECIR VERDAD, que el (los) ' + @TIPO_MATERIAL   
        +' declarado(s) a continuación,  se suministraron y facturaron al Operador del (de la) ' + @NOMBRE_CONTRATO + ' en el año '  
        + CAST(Year(GETDATE()) AS NVARCHAR(50)) + 'y que el cálculo de su Proporción de Contenido Nacional,se obtuvo de conformidad'  
        + 'con lo señalado en el "Acuerdo por el que se establece la Metodología para la Medición del Contenido'  
        + 'Nacional en Asignaciones y Contratos para la Exploración y Extracción de Hidrocarburos, así como para los'  
        + 'permisos en la Industria de Hidrocarburos" , y demás disposiciones jurídicas aplicables, además de que es'  
        +' correcta, completa, veraz y verificable.' AS PrimerInical,  
        '1. Los datos asentados en la presente carta pueden ser verificados por la Secretaría de Economía, por lo que, en caso de requerirlo, mi representada debe poner a disposición de la referida autoridad el soporte documental de lo declarado, en forma que establezcan las disposiciones jurídicas aplicables' AS PrimerParafo,  
        '2. Que está obligada a conservar el soporte documental de lo declarado en esta carta, por lo menos 5 años posteriores a que el Operador la presente a la Secretaría de Economía, y en caso de que se notifique al Operador que se va a verificar la información que haya reportado de contenido nacional, deberá conservar el soporte documental hasta que concluya la verificación; y que cuando se promueva algún recurso o juicio relacionado con la entrega de información o de su verificación, el plazo para conservar la información de contenido nacional, se computará a partir de la fecha en la que quede firme la resolución que le ponga fin al juicio o recurso, por lo que mi representada estará al tanto con el Operador.' AS SegundoParrafo,  
        '3. Las sanciones a que se puede hacer acreedora, por incumplir o entorpecer la obligación de informar el contenido nacional, conforme a las disposiciones jurídicas aplicables, incluido lo dispuesto en Título Cuarto, Capítulo I de la Ley del sector de Hidrocarburos, en particular lo previsto en los artículos 120, fracción II y 121, fracción III. ' AS TercerParrafo,  
        'Lo anterior, de conformidad con lo dispuesto en el punto 19 del Acuerdo por el que se establecen las disposiciones para que los Asignatarios, Contratistas y Permisionarios proporcionen información sobre contenido nacional en las actividades que realicen en la Industria de Hidrocarburos (el Acuerdo).' AS CuartoParrafo,  
        'Finalmente, se señala como domicilio para oír y recibir notificaciones relacionadas con lo dispuesto en el Acuerdo y demás disposiciones jurídicas aplicables, el ubicado en '  
        + CONCAT (  
        domicilio.TipoViabilidad, ' ', domicilio.Calle, CASE WHEN domicilio.NoExterior = '' THEN  
                       ''  
                    ELSE  
                     ', No. Exterior ' + domicilio.NoExterior  
                    END ,  
        CASE WHEN domicilio.NoInterior = '' THEN  
           ''  
        ELSE  
         ', No. Interior ' + domicilio.NoInterior  
        END, CASE WHEN domicilio.Colonia = '' THEN  
             ''  
          ELSE  
           ' Col. ' + domicilio.Colonia  
          END, CASE WHEN domicilio.Municipio = '' THEN  
               ''  
            ELSE  
             ', ' + domicilio.Municipio  
            END, ' ', domicilio.Estado, ' ', domicilio.Pais ,  
        CASE WHEN domicilio.CodigoPostal = '' THEN  
           ''  
        ELSE  
         ', C.P. ' + domicilio.CodigoPostal  
        END, CASE WHEN U.Correo = '' THEN  
             ''  
          ELSE  
           ', Correo Electrónico Contacto: ' + U.Correo  
          END, CASE WHEN P.Telefono = '' THEN '' ELSE ', Tel. ' + P.Telefono END )  
        + '. En caso de que este domicilio cambie, me comprometo a informárselo inmediatamente.' AS QuintoParrafo  
    FROM dbo.MPY_MM_AceptacionPedido AS AP  (NOLOCK)
		LEFT JOIN S_Proveedor AS P (NOLOCK) 
			ON P.IdProveedor = @IdProveedor 
			AND P.Activo = 1  
		LEFT JOIN DG_RepresentanteLegal RL (NOLOCK) 
			ON P.IdProveedor = RL.IdProveedor 
			AND RL.IsActivo =1  
		LEFT JOIN DG_ActaConstitutiva AC (NOLOCK)
			ON P.IdProveedor = AC.IdProveedor 
			AND AC.IsActivo = 1  
		LEFT JOIN S_UsuarioProveedor UP (NOLOCK)
			ON P.IdProveedor = UP.IdProveedor  
		LEFT JOIN S_Usuario U (NOLOCK)
			ON UP.IdUsuario = U.IdUsuario   
			AND U.Activo = 1
			AND ISNULL(U.IsEliminado,0) = 0
		LEFT JOIN Adinco.dbo.CO_SAPPO AS PO (NOLOCK)
			ON AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS  = PO.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS  
		LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS CP (NOLOCK)
			ON PO.Plant = CP.Planta  
		LEFT JOIN Adinco.dbo.CO_Contratista AS CON (NOLOCK)
			ON CP.IdContratista  = CON.IdContratista 
		LEFT JOIN Adinco.dbo.CO_Contratista AS C (NOLOCK)
			ON CAST(AP.IdProveedor AS INT) = C.IdContratista  
		LEFT JOIN Adinco.dbo.CO_SAPVendor SV (NOLOCK)
			ON AP.IdSubContratista COLLATE SQL_Latin1_General_CP1_CI_AS  = SV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS
		LEFT JOIN dbo.DG_Domicilio domicilio (NOLOCK)
			ON P.IdProveedor = domicilio.IdProveedor
				AND domicilio.IdTipoDomicilio = 1 
				AND domicilio.Activo = 1  
    WHERE AP.IdAceptacionPedido= @IdPedido  
    GROUP BY P.RazonSocial,
			P.RegimenCapital,
			RL.Nombre,
			RL.APaterno,
			RL.AMaterno,
			AC.Nombre, 
			SV.VendorName,
			CON.RazonSocial,  
			P.CURP, 
			domicilio.TipoViabilidad,
			domicilio.NombreViabilidad,
			domicilio.NoExterior,
			domicilio.NoInterior,
			domicilio.Colonia,
			domicilio.Municipio,
			domicilio.Estado, 
			domicilio.Pais,
			domicilio.CodigoPostal,
			P.CorreoProveedor,
			P.Telefono,
			domicilio.Calle,
			U.Correo,
			AP.IdSubContratista,
			AC.NoActaConstitutiva;

  END  
  ELSE  
  BEGIN  

  SET LANGUAGE spanish;  
  SELECT DISTINCT TOP 1  
  DAY ( GETDATE ()) AS DIA, DATENAME ( MONTH, DATEADD ( MONTH, MONTH ( GETDATE ()), -1 )) AS MES ,  
       RIGHT(CAST(YEAR ( GETDATE ()) AS CHAR(4)), 2) AS ANIO ,  
       'Ciudad de México, al ' + CAST(DAY ( GETDATE ()) AS NVARCHAR(2)) + ' de '  
       + CAST(DATENAME ( MONTH, DATEADD ( MONTH, MONTH ( GETDATE ()), -1 )) AS NVARCHAR(10)) + ' del '  
       + CONVERT ( NVARCHAR(10), YEAR ( GETDATE ())) AS FECHA,  
    CON.RazonSocial AS NombreOperadora,   
    CONCAT(RL.Nombre,' ',RL.APaterno,' ',RL.AMaterno) AS RepresentanteLegal,   
        'CARTA DEL PROVEEDOR DIRECTO DEL OPERADOR' AS Titulo,  
        'Por medio de la presente, el (la) que suscribe ' + CONCAT(RL.Nombre,' ',RL.APaterno,' ',RL.AMaterno)  
        +' representante legal de la empresa ' + ISNULL(P.RazonSocial,SV.VendorName)  
        + ' lo que acredito con el instrumento público número ' + CAST(AC.NoActaConstitutiva AS NVARCHAR(MAX))  
        + ', DECLARO BAJO PROTESTA DE DECIR VERDAD, que el (los) ' + @TIPO_MATERIAL   
        +' declarado(s) a continuación, se suministraron y facturaron al Operador del (de la) ' + @NOMBRE_CONTRATO + ' en el año '
        + CAST(Year(GETDATE()) AS NVARCHAR(50)) + ' cuenta(n) con la Proporción de Contenido Nacional que se señala en esta carta'  
        + ' y que mi representada la obtuvo de conformidad con lo establecido en el “Acuerdo por el '  
        + 'que se establece la Metodología para la Medición del Contenido Nacional en Asignaciones y '  
        + 'Contratos para la Exploración y Extracción de Hidrocarburos, así como para los permisos en '  
        + 'la Industria de Hidrocarburos”, y demás disposiciones jurídicas aplicables, es correcta, completa,'  
        +' veraz y verificable.' AS PrimerInical,  
        '1. Los datos asentados en la presente carta pueden ser verificados por la Secretaría de Economía, por lo que, en caso de requerirlo, mi representada debe poner a disposición de la referida autoridad el soporte documental de lo declarado, en forma que establezcan las disposiciones jurídicas aplicables' AS PrimerParafo,  
        '2. Que está obligada a conservar el soporte documental de lo declarado en esta carta, por lo menos 5 años posteriores a que el Operador la presente a la Secretaría de Economía, y en caso de que se notifique al Operador que se va a verificar la información que haya reportado de contenido nacional, deberá conservar el soporte documental hasta que concluya la verificación; y que cuando se promueva algún recurso o juicio relacionado con la entrega de información o de su verificación, el plazo para conservar la información de contenido nacional, se computará a partir de la fecha en la que quede firme la resolución que le ponga fin al juicio o recurso, por lo que mi representada estará al tanto con el Operador.' AS SegundoParrafo,  
        '3. Las sanciones a que se puede hacer acreedora, por incumplir o entorpecer la obligación de informar el contenido nacional, conforme a las disposiciones jurídicas aplicables, incluido lo dispuesto en Título Cuarto, Capítulo I de la Ley del sector de Hidrocarburos, en particular lo previsto en los artículos 120, fracción II y 121, fracción III. ' AS TercerParrafo,  
        'Lo anterior, de conformidad con lo dispuesto en el punto 19 del Acuerdo por el que se establecen las disposiciones para que los Asignatarios, Contratistas y Permisionarios proporcionen información sobre contenido nacional en las actividades que realicen en la Industria de Hidrocarburos (el Acuerdo).' AS CuartoParrafo,  
        'Finalmente, se señala como domicilio para oír y recibir notificaciones relacionadas con lo dispuesto en el Acuerdo y demás disposiciones jurídicas aplicables, el ubicado en '  
        + CONCAT (  
        domicilio.TipoViabilidad, ' ', domicilio.Calle, CASE WHEN domicilio.NoExterior = '' THEN  
                       ''  
                    ELSE  
                     ', No. Exterior ' + domicilio.NoExterior  
                    END ,  
        CASE WHEN domicilio.NoInterior = '' THEN  
           ''  
        ELSE  
         ', No. Interior ' + domicilio.NoInterior  
        END, CASE WHEN domicilio.Colonia = '' THEN  
             ''  
          ELSE  
           ' Col. ' + domicilio.Colonia  
          END, CASE WHEN domicilio.Municipio = '' THEN  
               ''  
            ELSE  
             ', ' + domicilio.Municipio  
            END, ' ', domicilio.Estado, ' ', domicilio.Pais ,  
        CASE WHEN domicilio.CodigoPostal = '' THEN  
           ''  
        ELSE  
         ', C.P. ' + domicilio.CodigoPostal  
        END, CASE WHEN U.Correo = '' THEN  
             ''  
          ELSE  
           ', Correo Electrónico Contacto: ' + U.Correo  
          END, CASE WHEN P.Telefono = '' THEN '' ELSE ', Tel. ' + P.Telefono END )  
        + '. En caso de que este domicilio cambie, me comprometo a informárselo inmediatamente.' AS QuintoParrafo  
    FROM dbo.MPY_MM_AceptacionPedido AS AP (NOLOCK)
		LEFT JOIN S_Proveedor AS P (NOLOCK)
			ON P.IdProveedor = @IdProveedor 
			AND P.Activo = 1  
		LEFT JOIN DG_RepresentanteLegal RL (NOLOCK)
			ON RL.IdProveedor = @IdProveedor 
			AND RL.IsActivo =1  
		LEFT JOIN DG_ActaConstitutiva AC (NOLOCK)
			ON AC.IdProveedor = @IdProveedor 
				AND AC.IsActivo = 1  
		LEFT JOIN S_UsuarioProveedor UP (NOLOCK)
			ON P.IdProveedor = UP.IdProveedor  
		LEFT JOIN S_Usuario U (NOLOCK)
			ON UP.IdUsuario = U.IdUsuario  
			AND U.Activo = 1
			AND ISNULL(U.IsEliminado,0) = 0
		LEFT JOIN Adinco.dbo.CO_SAPPO AS PO (NOLOCK)
			ON AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS = PO.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS  
		LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS CP (NOLOCK)
			ON PO.Plant = CP.Planta 
		LEFT JOIN Adinco.dbo.CO_Contratista AS CON (NOLOCK)
			ON CP.IdContratista = CON.IdContratista  
		LEFT JOIN Adinco.dbo.CO_Contratista AS C (NOLOCK)
			ON CAST(AP.IdProveedor AS INT) = C.IdContratista 
		LEFT JOIN Adinco.dbo.CO_SAPVendor SV (NOLOCK)
			ON AP.IdSubContratista COLLATE SQL_Latin1_General_CP1_CI_AS = SV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS 
		LEFT JOIN dbo.DG_Domicilio domicilio (NOLOCK)
			ON P.IdProveedor = domicilio.IdProveedor 
			AND domicilio.IdTipoDomicilio = 1 
			AND domicilio.Activo = 1  
    WHERE AP.IdAceptacionPedido = @IdPedido   
    GROUP BY RL.Nombre,  
			 RL.APaterno,  
			 RL.AMaterno,  
			 AC.Nombre,   
			 AC.NoActaConstitutiva,  
			 AP.IdProveedor,  
			 AP.IdDomicilioEntrega,  
			 AP.IdSubContratista,  
			 P.RazonSocial,  
			 SV.VendorName,  
			 CON.RazonSocial,  
			 domicilio.TipoViabilidad,  
			 domicilio.Calle,  
			 domicilio.NoExterior,  
			 domicilio.NoInterior,  
			 domicilio.Colonia,  
			 domicilio.Municipio,  
			 domicilio.Estado,  
			 domicilio.Pais,  
			 domicilio.CodigoPostal,  
			 U.Correo,  
			 P.Telefono,  
			 C.NombreContratista;
  END; 
   
  END;  

END;


END;