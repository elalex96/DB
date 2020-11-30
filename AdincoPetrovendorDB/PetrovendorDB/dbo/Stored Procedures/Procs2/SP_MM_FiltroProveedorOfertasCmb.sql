-- =============================================
-- Author:		DANIEL AC
-- Create date: 20-09-17
-- Description:	Consultar FILTRO DE PROVEEDORES
-- =============================================
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 05-Jun-18
-- Description:	se agrega el filtro por giro empresarial y por materiales
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 16/Jul/2019
-- Description:	se agrego la lista negra del sat
-- =============================================
-- Author:		Abel Rivera
-- Create date: 16/Jul/2019
-- Description:	Se agrega el campo para validar la lista negra al select
-- =============================================

CREATE PROCEDURE [dbo].[SP_MM_FiltroProveedorOfertasCmb]
	-- Add the parameters for the stored procedure here
	@Origen INT, @IsPaises NVARCHAR(MAX), @IdEstados NVARCHAR(MAX), @IdTamanioEmpresa INT ,
	@CalificacionMayor NVARCHAR(MAX), @AniosExperiencias INT, @CapitalContableMinimo FLOAT, @IdISOS NVARCHAR(MAX) ,
	@IdProveedorActual INT, @NumeroISOS INT, @ALL NVARCHAR(300)
AS
	BEGIN
		SET NOCOUNT ON

		DECLARE @IdPaisMexico INT = 42
		DECLARE @SQL_QUERY NVARCHAR(MAX) = ''
		DECLARE @FILTRO_BUSQUEDA_ORIGEN NVARCHAR(MAX) = ''
		DECLARE @FILTRO_BUSQUEDA_TAMANIO NVARCHAR(MAX) = ''
		DECLARE @FILTRO_BUSQUEDA_EXPERIENCIA NVARCHAR(MAX) = ''
		DECLARE @FILTRO_BUSQUEDA_ISOS NVARCHAR(MAX) = ''
		DECLARE @FILTRO_BUSQUEDA_CAPITAL NVARCHAR(MAX) = ''
		DECLARE @FILTRO_BUSQUEDA_CALIFICACION NVARCHAR(MAX) = ''
		DECLARE @FILTRO_INNERS_ORIGEN NVARCHAR(MAX) = ''
		DECLARE @FILTRO_INNERS_TAMANIO NVARCHAR(MAX) = ''
		DECLARE @FILTRO_INNERS_EXPERIENCIA NVARCHAR(MAX) = ''
		DECLARE @FILTRO_INNERS_ISOS NVARCHAR(MAX) = ''
		DECLARE @STRING NVARCHAR(MAX) = ''

		IF @Origen <> 0
		   AND	@ALL = 'BUSCARxFILTRO'
			BEGIN
				--- ORIGEN ---
				IF @IsPaises = '' SET @IsPaises = '0'

				IF @IdEstados = '' SET @IdEstados = '0'

				IF @IdISOS = '' SET @IdISOS = '0'

				SET @FILTRO_BUSQUEDA_ORIGEN
					= CASE @Origen
					  WHEN 2 THEN ---Proveedores Extranjeros
						  @FILTRO_BUSQUEDA_ORIGEN + ' AND (P.IdPais IN (' + ISNULL ( @IsPaises, '0' )
						  + ') OR  D.IdPais IN  (' + ISNULL ( @IsPaises, '0' ) + '))'
					  WHEN 3 THEN ---Proveedores Nacionales					 
						  @FILTRO_BUSQUEDA_ORIGEN + ' AND P.IdPais = ' + CAST(@IdPaisMexico AS NVARCHAR(100))
					  END
				SET @FILTRO_INNERS_ORIGEN
					= CASE @Origen
					  WHEN 2 THEN --- Proveedores Nacionales
						  @FILTRO_INNERS_ORIGEN + 'INNER JOIN DG_Domicilio AS D ON D.IdProveedor = P.IdProveedor   '
					  WHEN 3 THEN --- Proveedores Nacionales
						  @FILTRO_INNERS_ORIGEN + ' INNER JOIN DG_Domicilio AS D ON D.IdProveedor = P.IdProveedor   '
					  END

				--- TAMAÑO DE EMPRESA 
				IF @IdTamanioEmpresa <> 0
					BEGIN
						SET @FILTRO_BUSQUEDA_TAMANIO
							= N'  AND CE.IdClasificacionEmpresa = ' + CAST(@IdTamanioEmpresa AS NVARCHAR(100)) + N' '
					END
				ELSE BEGIN
						 SET @FILTRO_BUSQUEDA_TAMANIO = N''
					END

				IF @IdTamanioEmpresa IS NOT NULL
					BEGIN
						SET @FILTRO_INNERS_TAMANIO
							= N' INNER join PV_ClasificacionEmpresaProveedor AS CE ON CE.IdProveedor = P.IdProveedor '
							  + N' INNER join PV_ClasificacionPyMES AS CP ON CP.IdClasificacion = CE.IdClasificacionEmpresa '
					END
				ELSE BEGIN
						 SET @FILTRO_INNERS_TAMANIO = N''
					END

				--- AÑOS DE EXPERIENCIA
				IF @AniosExperiencias IS NOT NULL
					BEGIN
						SET @FILTRO_INNERS_EXPERIENCIA
							= N' INNER JOIN PV_PerfilEmpresa AS PE ON PE.IdProveedor =P. IdProveedor '
						SET @FILTRO_BUSQUEDA_EXPERIENCIA
							= N' AND ISNULL(PE.AniosExperiencia,0) >= ' + CAST(@AniosExperiencias AS NVARCHAR(100))
							  + N' '
					END

				--- ISOS REQUERIDOS 
				IF @IdISOS = ''
				   OR	@IdISOS = '0'
					BEGIN
						SET @FILTRO_BUSQUEDA_ISOS = N''
						SET @FILTRO_INNERS_ISOS = N''
					END
				ELSE
					BEGIN
						SET @FILTRO_BUSQUEDA_ISOS = N' '
						SET @FILTRO_INNERS_ISOS
							= N' AND ' + CAST(@NumeroISOS AS NVARCHAR(MAX))
							  + N' = (SELECT COUNT(IdTipoDocSG) FROM PV_SistemaGestion WHERE  IdProveedor= P.IdProveedor and IdTipoDocSG IN ('
							  + @IdISOS + N') AND Activo = 1) '
					END

				--- CAPITAL CONTABLE 
				IF @CapitalContableMinimo IS NOT NULL
					BEGIN
						SET @FILTRO_BUSQUEDA_CAPITAL
							= N' AND ISNULL(P.CapitalContable,0) >= ' + CAST(@CapitalContableMinimo AS NVARCHAR(MAX))
							  + N' '
					END

				--- CALIFICACION ESTRELLAS 
				IF @CalificacionMayor <> ''
					BEGIN
						SET @FILTRO_BUSQUEDA_CALIFICACION
							= N' HAVING [dbo].[ObtenerEstrellasModificado] (P.IdProveedor) IN (' + @CalificacionMayor
							  + N') '
					END
				ELSE BEGIN
						 SET @FILTRO_BUSQUEDA_CALIFICACION = N''
					END

				---SET @STRING = CONCAT(CAST(@Origen AS NVARCHAR(MAX)),',', @IsPaises,',',  @IdEstados,',', CAST(@IdTamanioEmpresa AS NVARCHAR(MAX)) ,',', CAST(@CalificacionMayor AS NVARCHAR(MAX)),',', CAST(@AniosExperiencias AS NVARCHAR(MAX)),',', CAST(@CapitalContableMinimo AS NVARCHAR(MAX)),',', @IdISOS,',', CAST(@IdProveedorActual AS NVARCHAR(MAX)) )
				SET @SQL_QUERY
					= N'SELECT P.IdProveedor, CONCAT(P.RazonSocial,''' + N'  '
					  + N''', P.RegimenCapital ) AS NombreProveedor,  [dbo].[ObtenerEstrellasModificado] (P.IdProveedor) AS Estrellas  '
					  + N'FROM S_Proveedor AS P '
					  + N'INNER JOIN S_UsuarioProveedor AS UP ON UP.IdProveedor =  P.IdProveedor '
					  + +N'##FILTRO_INNER_ORIGEN## ' + N'##FILTRO_INNER_TAMANIO## ' + +N'##FILTRO_INNER_EXPERIENCIA## '
					  + +N'##FILTRO_INNER_ISOS## ' + +N'WHERE P.Activo = 1 AND P.IdProveedor <> '
					  + CAST(@IdProveedorActual AS NVARCHAR(350)) + N' ' + N'##FILTRO_BUSQUEDA_ORIGEN## '
					  + N'##FILTRO_BUSQUEDA_TAMANIO## ' + N'##FILTRO_BUSQUEDA_EXPERIENCIA## '
					  + N'##FILTRO_BUSQUEDA_ISOS## ' + N'##FILTRO_BUSQUEDA_CAPITAL## '
					  + N'GROUP BY P.IdProveedor, P.RazonSocial,  P.RegimenCapital, [dbo].[ObtenerEstrellasModificado] (P.IdProveedor) '
					  + N'##FILTRO_CALIFICACION##' + N'ORDER BY NombreProveedor '
				SET @FILTRO_BUSQUEDA_ORIGEN = ISNULL ( @FILTRO_BUSQUEDA_ORIGEN, '' )
				SET @FILTRO_INNERS_ORIGEN = ISNULL ( @FILTRO_INNERS_ORIGEN, '' )
				SET @SQL_QUERY =
					( SELECT	REPLACE ( @SQL_QUERY, '##FILTRO_INNER_ORIGEN##', @FILTRO_INNERS_ORIGEN ))
				SET @SQL_QUERY =
					( SELECT	REPLACE ( @SQL_QUERY, '##FILTRO_BUSQUEDA_ORIGEN##', @FILTRO_BUSQUEDA_ORIGEN ))
				SET @SQL_QUERY =
					( SELECT	REPLACE ( @SQL_QUERY, '##FILTRO_INNER_TAMANIO##', @FILTRO_INNERS_TAMANIO ))
				SET @SQL_QUERY =
					( SELECT	REPLACE ( @SQL_QUERY, '##FILTRO_BUSQUEDA_TAMANIO##', @FILTRO_BUSQUEDA_TAMANIO ))
				SET @SQL_QUERY =
					( SELECT	REPLACE ( @SQL_QUERY, '##FILTRO_INNER_EXPERIENCIA##', @FILTRO_INNERS_EXPERIENCIA ))
				SET @SQL_QUERY =
					( SELECT	REPLACE ( @SQL_QUERY, '##FILTRO_BUSQUEDA_EXPERIENCIA##', @FILTRO_BUSQUEDA_EXPERIENCIA ))
				SET @SQL_QUERY =
					( SELECT REPLACE (	  @SQL_QUERY, '##FILTRO_INNER_ISOS##', @FILTRO_INNERS_ISOS ))
				SET @SQL_QUERY =
					( SELECT	REPLACE ( @SQL_QUERY, '##FILTRO_BUSQUEDA_ISOS##', @FILTRO_BUSQUEDA_ISOS ))
				SET @SQL_QUERY =
					( SELECT	REPLACE ( @SQL_QUERY, '##FILTRO_BUSQUEDA_CAPITAL##', @FILTRO_BUSQUEDA_CAPITAL ))
				SET @SQL_QUERY =
					( SELECT	REPLACE ( @SQL_QUERY, '##FILTRO_CALIFICACION##', @FILTRO_BUSQUEDA_CALIFICACION ))

				---execute	SP_MM_FiltroProveedorOfertas    1,'','',0,'',0,0,'',420,0
				--- Select @SQL_QUERY
				EXECUTE sp_executesql @SQL_QUERY

			--DECLARE @ESTRELLAS INT 
			--EXEC dbo.SP_EP_ObtenerEstrellas @IdProveedorActual,@ESTRELLAS OUTPUT
			END
		ELSE
			BEGIN
				SELECT		P.IdProveedor,
							CASE
								WHEN LN.RFC IS NULL THEN CONCAT ( P.RazonSocial , '  ', P.RegimenCapital ) 
								ELSE CONCAT ( P.RazonSocial , '  ', P.RegimenCapital , ' - DESHABILITADO POR SAT - [Situación: ', LN.Situacion COLLATE Modern_Spanish_CI_AS,']')
							END AS NombreProveedor ,
							dbo.ObtenerEstrellasModificado ( p.IdProveedor ) AS Estrellas, P.CorreoProveedor,
							CASE WHEN LN.RFC  IS NULL THEN 0 ELSE 1 END AS InBlackList
				FROM		S_Proveedor AS P
				INNER JOIN	S_UsuarioProveedor AS UP
					ON UP.IdProveedor = P.IdProveedor
				LEFT JOIN	PV_ClasificacionEmpresaProveedor AS CE
					ON CE.IdProveedor = P.IdProveedor
				LEFT JOIN	PV_ClasificacionPyMES AS CP
					ON CP.IdClasificacion = CE.IdClasificacionEmpresa
				LEFT JOIN	PV_PerfilEmpresa AS PE
					ON PE.IdProveedor = P.IdProveedor
				LEFT JOIN	dbo.PV_PerfilGiroEmpresarial PGE
					ON PGE.IdProveedor = P.IdProveedor
				LEFT JOIN	dbo.PV_GiroEmpresarial GE
					ON PGE.IdGiroEmpresarial = GE.IdGiroProveedor
				LEFT JOIN Adinco.dbo.ListaNegra AS LN
					ON LN.RFC COLLATE Modern_Spanish_CI_AS = P.RFC COLLATE Modern_Spanish_CI_AS
				WHERE
							P.Activo = 1
							AND P.IdProveedor <> @IdProveedorActual
							AND ISNULL ( PE.AniosExperiencia, 0 ) >= 0
							AND ISNULL ( P.CapitalContable, 0 ) >= 0
				GROUP BY	P.IdProveedor, P.RazonSocial, P.RegimenCapital, P.CorreoProveedor,LN.RFC,LN.Situacion
				ORDER BY	NombreProveedor
			END
	END
