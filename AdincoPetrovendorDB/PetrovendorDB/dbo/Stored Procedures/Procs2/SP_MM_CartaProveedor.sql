-- =============================================
-- Author:		Manuel Cruz
-- Create date: 26-06-17
-- Description:	
-- =============================================
--Tener en cuenta que no se utiliz aen realidad el IdPedido sino el Id Aceptacion, me imagino que no se corrigio para no tener que mover el nombre y mover codigo del lado del servidor
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 31-07-2018
-- Description:	 se verifica que los usuarios esten activos, ademas de empezar la lista por el administrador para que se muestre su correo,
--	en caso de estar desactivado pasa al siguiente usuario activo
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 11-03-2019
-- Description:	 se modifica la consulta ya que ahora puede tener mas de un representante legal
-- =============================================

CREATE PROCEDURE [dbo].[SP_MM_CartaProveedor]
	-- Add the parameters for the stored procedure here
	@IdProveedor INT, @IdPedido INT, @IdContrato INT, @IdUsuario INT, @fchRegistro DATETIME ,
	@IdsRepresentanteLegal NVARCHAR (MAX)
AS
	BEGIN
		SET NOCOUNT ON

		DECLARE @IdTipoRegimen INT
		DECLARE @NombreOperadora NVARCHAR (MAX)

		DECLARE @TablaIdsRepresentanteLegal TABLE
			( IdRepresentante INT )

		SET @IdTipoRegimen = ( SELECT IdTipoRegimen	  FROM S_PROVEEDOR WHERE IdProveedor =	  @IdProveedor )

		IF ( @IdTipoRegimen = 2 )
			BEGIN
				DECLARE @UsuarioFisico NVARCHAR (MAX) = (	SELECT	TOP 1
																	U.Nombre AS RepresentanteLegal
															  FROM	S_Proveedor AS P
																	JOIN S_UsuarioProveedor UP
																		 ON P.IdProveedor = UP.IdProveedor
																	JOIN S_Usuario U
																		 ON UP.IdUsuario = U.IdUsuario
															 WHERE
																	U.IdTipoUsuario = 3
																	AND P.IdProveedor = @IdProveedor )
			END

		DECLARE @RepresentanteLegal NVARCHAR (MAX)

		DECLARE @tablaAux TABLE
			( IdContrato INT ,
			  NombreContrato NVARCHAR (MAX) ,
			  NombreOperadora NVARCHAR (MAX) ,
			  IdAceptacionPedido INT )

		INSERT INTO @tablaAux
			( IdContrato, NombreContrato, NombreOperadora, IdAceptacionPedido )
		SELECT	SP.IdContrato, N'Contrato ' + NumeroContrato, prov.RazonSocial, AP.IdAceptacionPedido
		  FROM	MM_SolicitudPedido AS SP
				INNER JOIN MM_PeticionOferta AS PO
						   ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
				INNER JOIN MM_Pedido AS P
						   ON P.IdPeticionOferta = PO.IdPeticionOferta
				INNER JOIN MM_AceptacionPedido AS AP
						   ON AP.IdPedido = P.IdPedido
				INNER JOIN Adinco.dbo.CO_Contrato c
						   ON c.IdContrato = SP.IdContrato
				INNER JOIN dbo.S_Proveedor prov
						   ON prov.IdProveedor = P.IdProveedorCompras
		 WHERE	AP.IdAceptacionPedido = @IdPedido

		IF ( @IdTipoRegimen = 2 )
			BEGIN
				SET LANGUAGE spanish

				SELECT	'Por medio de la presente, el (la) que suscribe ' + DAY ( GETDATE ()) AS DIA ,
						DATENAME ( MONTH, DATEADD ( MONTH, MONTH ( GETDATE ()), -1 )) AS MES ,
						RIGHT(CAST(YEAR ( GETDATE ()) AS CHAR (4)), 2) AS ANIO ,
						'Ciudad de México, al ' + CAST(DAY ( GETDATE ()) AS NVARCHAR (2)) + ' de '
						+ CAST(DATENAME ( MONTH, DATEADD ( MONTH, MONTH ( GETDATE ()), -1 )) AS NVARCHAR (10))
						+ ' del ' + CONVERT ( NVARCHAR (10), YEAR ( GETDATE ())) AS FECHA ,
						t.NombreOperadora AS NombreOperadora, @UsuarioFisico AS RepresentanteLegal ,
						CONCAT ( P.RazonSocial, ' ' ) AS NombreProveedor, P.CURP AS NoActaConstitutiva ,
						TSP.TipoSolicitudPedido AS Listado, t.NombreContrato AS TipoInstrumento ,
						YEAR ( GETDATE ()) AS AnioFacturas ,
						CONCAT (
							domicilio.TipoViabilidad, ' ', domicilio.Calle ,
							CASE WHEN domicilio.NoExterior = '' THEN
									 ''
								ELSE
									', No. Exterior ' + domicilio.NoExterior
							END, CASE WHEN domicilio.NoInterior = '' THEN
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
										 ', Correo Electronico Contacto: ' + U.Correo
								 END, CASE WHEN P.Telefono = '' THEN '' ELSE ', Tel. ' + P.Telefono END ) AS Domicilio ,
						' ' AS Carta
				  FROM	S_Proveedor P
						LEFT JOIN DG_RepresentanteLegal RL
								  ON P.IdProveedor = RL.IdProveedor
									 AND RL.IsActivo = 1
						LEFT JOIN DG_ActaConstitutiva AC
								  ON P.IdProveedor = AC.IdProveedor
									 AND AC.IsActivo = 1
						LEFT JOIN S_UsuarioProveedor UP
								  ON P.IdProveedor = UP.IdProveedor
						LEFT JOIN S_Usuario U
								  ON UP.IdUsuario = U.IdUsuario
						LEFT JOIN MM_Pedido MP
								  ON MP.IdSubcontratista = P.IdProveedor
						LEFT JOIN MM_AceptacionPedido AS AP
								  ON AP.IdPedido = MP.IdPedido
									 AND MP.IdUsuarioRecepcionServicio = u.IdUsuario
						LEFT JOIN MM_PeticionOferta AS PO
								  ON PO.IdPeticionOferta = MP.IdPeticionOferta
						LEFT JOIN MM_SolicitudPedido SP
								  ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
						LEFT JOIN MM_TipoSolicitudPedido TSP
								  ON SP.IdTipoSolicitudPedido = TSP.IdTipoSolicitudPedido
						LEFT JOIN dbo.DG_Domicilio domicilio
								  ON domicilio.IdProveedor = P.IdProveedor
									 AND domicilio.IdTipoDomicilio = 1
									 AND domicilio.Activo = 1
						INNER JOIN @tablaAux t
								   ON AP.IdAceptacionPedido = t.IdAceptacionPedido
				 WHERE
						P.IdProveedor = @IdProveedor
						AND AP.IdAceptacionPedido = @IdPedido
						AND U.Activo = 1
						AND ( U.IdTipoUsuario = 3 OR U.IdTipoUsuario <> 3 )
				 GROUP BY P.RazonSocial, P.RegimenCapital, RL.Nombre, RL.APaterno, RL.AMaterno, AC.Nombre, P.CURP ,
						  TSP.TipoSolicitudPedido, domicilio.TipoViabilidad, domicilio.NombreViabilidad ,
						  domicilio.NoExterior, domicilio.NoInterior, domicilio.Colonia, domicilio.Municipio ,
						  domicilio.Estado, domicilio.Pais, domicilio.CodigoPostal, P.CorreoProveedor, P.Telefono ,
						  domicilio.Calle, U.Correo, U.IdTipoUsuario, t.NombreOperadora, t.NombreContrato
				 ORDER BY CASE WHEN U.IdTipoUsuario = 3 THEN '1' ELSE '2' END ASC
			END
		ELSE
			BEGIN
				SET LANGUAGE spanish

				INSERT INTO @TablaIdsRepresentanteLegal
					( IdRepresentante )
				SELECT splitdata  FROM dbo .fnSplitString ( @IdsRepresentanteLegal, ' ' )

				SELECT	@RepresentanteLegal
					= STUFF (
					  (	  SELECT	CAST(', ' AS VARCHAR (MAX))
									+ CONCAT ( legal.Nombre, ' ', legal.APaterno, ' ', legal.AMaterno )
							FROM	dbo.DG_RepresentanteLegal legal
									INNER JOIN @TablaIdsRepresentanteLegal carta
											   ON legal.IdRepresentanteLegal = carta.IdRepresentante
						  FOR XML PATH ( '' )), 1, 1, '' )

				SELECT	CONCAT (
							'Por medio de la presente, el (la) que suscribe ' , @RepresentanteLegal ,
							' representante legal de la empresa ' , CONCAT ( P.RazonSocial, ' ', P.RegimenCapital ) ,
							' lo que acredito con el instrumento público número ' , acta.NoActaConstitutiva ,
							' DECLARO BAJO PROTESTA DE DECIR VERDAD, que el (los) ' , TSP.TipoSolicitudPedido ,
							' declarado(s), a continuación , se suministraron y facturaron al Operador del (de la) ' ,
							t.NombreContrato, ' en el año ', YEAR ( GETDATE ()) ,
							' y que el cálculo de su Proporción de Contenido Nacional,se obtuvo de conformidad con lo señalado en el ' ,
							'“Acuerdo por el que se establece la Metodología para la Medición del Contenido Nacional en Asignaciones y ' ,
							'Contratos para la Exploración y Extracción de Hidrocarburos, así como para los permisos en la Industria de Hidrocarburos”, ' ,
							'y demás disposiciones jurídicas aplicables, además de que es correcta, completa, veraz y verificable.' ) AS Carta ,
						DAY ( GETDATE ()) AS DIA, DATENAME ( MONTH, DATEADD ( MONTH, MONTH ( GETDATE ()), -1 )) AS MES ,
						RIGHT(CAST(YEAR ( GETDATE ()) AS CHAR (4)), 2) AS ANIO ,
						'Ciudad de México, al ' + CAST(DAY ( GETDATE ()) AS NVARCHAR (2)) + ' de '
						+ CAST(DATENAME ( MONTH, DATEADD ( MONTH, MONTH ( GETDATE ()), -1 )) AS NVARCHAR (10))
						+ ' del ' + CONVERT ( NVARCHAR (10), YEAR ( GETDATE ())) AS FECHA ,
						t.NombreOperadora AS NombreOperadora, @RepresentanteLegal AS RepresentanteLegal ,
						CONCAT ( P.RazonSocial, ' ', P.RegimenCapital ) AS NombreProveedor ,
						acta.NoActaConstitutiva AS NoActaConstitutiva, TSP.TipoSolicitudPedido AS Listado ,
						t.NombreContrato AS TipoInstrumento, YEAR ( GETDATE ()) AS AnioFacturas ,
						CONCAT (
							domicilio.TipoViabilidad, ' ', domicilio.Calle ,
							CASE WHEN domicilio.NoExterior = '' THEN
									 ''
								ELSE
									', No. Exterior ' + domicilio.NoExterior
							END, CASE WHEN domicilio.NoInterior = '' THEN
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
										 ', Correo Electronico Contacto: ' + U.Correo
								 END, CASE WHEN P.Telefono = '' THEN '' ELSE ', Tel. ' + P.Telefono END ) AS Domicilio
				  FROM	S_Proveedor P
						LEFT JOIN S_UsuarioProveedor UP
								  ON P.IdProveedor = UP.IdProveedor
						INNER JOIN S_Usuario U
								   ON UP.IdUsuario = U.IdUsuario
						LEFT JOIN dbo.DG_ActaConstitutiva acta
								  ON acta.IdProveedor = P.IdProveedor
									 AND acta.IsActivo = 1
						LEFT JOIN MM_Pedido MP
								  ON MP.IdSubcontratista = P.IdProveedor
						LEFT JOIN MM_AceptacionPedido AS AP
								  ON AP.IdPedido = MP.IdPedido
						LEFT JOIN MM_PeticionOferta AS PO
								  ON PO.IdPeticionOferta = MP.IdPeticionOferta
						LEFT JOIN MM_SolicitudPedido SP
								  ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
						LEFT JOIN MM_TipoSolicitudPedido TSP
								  ON SP.IdTipoSolicitudPedido = TSP.IdTipoSolicitudPedido
						LEFT JOIN dbo.DG_Domicilio domicilio
								  ON domicilio.IdProveedor = P.IdProveedor
									 AND domicilio.IdTipoDomicilio = 1
									 AND domicilio.Activo = 1
						INNER JOIN @tablaAux t
								   ON AP.IdAceptacionPedido = t.IdAceptacionPedido
				 WHERE
						P.IdProveedor = @IdProveedor
						AND AP.IdAceptacionPedido = @IdPedido
						AND U.Activo = 1
						AND ( U.IdTipoUsuario = 3 OR U.IdTipoUsuario <> 3 )
				 ORDER BY CASE WHEN U.IdTipoUsuario = 3 THEN '1' ELSE '2' END ASC
			END
	END
