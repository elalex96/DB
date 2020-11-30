-- =============================================
-- Author:		Pedro Acu�a
-- Create date: 14/09/2018
-- Description:	consultar los documentos cargados en procura Tipo Documento (ADM_TipoDocumentosS3 )
--1 Documentos por material SolPed
--2 Documentos Anexos SolPed 
--3 Fianza solOferta
--4 Bases solOferta
--5 Adj Directa Justificacion solOferta
--6 Mercadeo Justificacion solOferta
--7 Aceptacion de servicio
--Actua 27-DIC-2018 se agrego filtro de idrequisici�n a la consulta de documentos de tipo 10 (Daniel AC)
-- =============================================

CREATE PROCEDURE [dbo].[SP_ADM_ConsultaDocumentosS3] @IdSolicitudPedido INT
AS
	BEGIN
		DECLARE @tablaAux TABLE(Fila INT IDENTITY ,
								TipoDocumento INT ,
								IdDocumento INT ,
								NombreDoc NVARCHAR(MAX) ,
								Activo BIT ,
								Descripcion NVARCHAR(MAX) ,
								AceptacionDocumento NVARCHAR(MAX) ,
								IdAceptacionPedido INT ,
								NombreUsuario NVARCHAR(150) ,
								FechaCarga DATETIME)
		DECLARE @TablaAceptacionMateriales TABLE(IdAceptacionPedido int	, Materiales NVARCHAR(MAX))
		DECLARE @TablaAceptacion TABLE(TipoDocumento INT ,
								IdDocumento INT ,
								NombreDoc NVARCHAR(MAX) ,
								Activo BIT ,
								Descripcion NVARCHAR(MAX) ,
								AceptacionDocumento NVARCHAR(MAX) ,
								IdAceptacionPedido INT ,
								NombreUsuario NVARCHAR(150) ,
								FechaCarga DATETIME)

		INSERT INTO @tablaAux
		(TipoDocumento, IdDocumento, NombreDoc, Activo, Descripcion, NombreUsuario, FechaCarga)
					SELECT	1, doc.IdSolPedMaterialDocumentoAdj, doc.NombreArchivoAdjunto, doc.Activo ,
							CONVERT(NVARCHAR(50), det.Cantidad)+' - '+m.DescripcionCorta+' - '+m.Modelo, u.Nombre ,
							doc.CreadoEl
					FROM	MM_SolPedArchivoAdjuntoMaterial doc
							INNER JOIN dbo.MM_SolicitudPedidoDetalle det ON det.IdSolicitudPedidoDetalle=doc.IdSolPedDetalle
							LEFT JOIN dbo.MM_Material m ON m.IdMaterial=det.IdMaterial
							LEFT JOIN dbo.S_Usuario u ON u.IdUsuario=doc.CreadoPor
					WHERE	det.IdSolicitudPedido=@IdSolicitudPedido AND doc.Activo=1
							AND	  ISNULL(det.IdEstatusEliminado, 0)=0

		INSERT INTO @tablaAux(TipoDocumento, IdDocumento, NombreDoc, Activo, NombreUsuario, FechaCarga)
					SELECT	2, IdDocumento, NombreDoc, doc.Activo, u.Nombre, doc.CreadoEl
					FROM	dbo.MM_DocumentosSolPed doc
							INNER JOIN dbo.MM_SolicitudPedido solPed ON solPed.IdSolicitudPedido=doc.IdSolPed
							LEFT JOIN dbo.S_Usuario u ON u.IdUsuario=doc.CreadoPor
					WHERE	IdSolPed=@IdSolicitudPedido AND doc.Activo=1 AND ISNULL(solPed.IdEstatusEliminado, 0)=0

		INSERT INTO @tablaAux(TipoDocumento, IdDocumento, NombreDoc, Activo, NombreUsuario, FechaCarga)
					SELECT	3, IdDocFianza, NombreDoc, doc.Activo, u.Nombre, doc.CreadoEl
					FROM	dbo.TA_DocFianzaOperacion doc
							INNER JOIN dbo.TA_Operacion TAO ON TAO.IdOperacion=doc.IdOperacion
							INNER JOIN dbo.MM_SolicitudPedido solPed ON TAO.IdDocumento=solPed.IdSolicitudPedido
							LEFT JOIN dbo.S_Usuario u ON u.IdUsuario=doc.CreadoPor
					WHERE	doc.IdOperacion IN(SELECT	IdOperacion
											   FROM dbo.TA_Operacion
											   WHERE IdDocumento=@IdSolicitudPedido AND IdTipoOperacion=6)
							AND	  doc.Activo=1 AND TAO.IdTipoOperacion=6 AND  ISNULL(solPed.IdEstatusEliminado, 0)=0

		INSERT INTO @tablaAux(TipoDocumento, IdDocumento, NombreDoc, Activo, NombreUsuario, FechaCarga)
					SELECT	4, IdDocBases, NombreDoc, doc.Activo, u.Nombre, doc.CreadoEl
					FROM	dbo.TA_DocBasesOperacion doc
							INNER JOIN dbo.TA_Operacion TAO ON TAO.IdOperacion=doc.IdOperacion
							INNER JOIN dbo.MM_SolicitudPedido solPed ON TAO.IdDocumento=solPed.IdSolicitudPedido
							LEFT JOIN dbo.S_Usuario u ON u.IdUsuario=doc.CreadoPor
					WHERE	doc.IdOperacion IN(SELECT	IdOperacion
											   FROM dbo.TA_Operacion
											   WHERE IdDocumento=@IdSolicitudPedido AND IdTipoOperacion=6)
							AND	  doc.Activo=1 AND TAO.IdTipoOperacion=6 AND  ISNULL(solPed.IdEstatusEliminado, 0)=0

		INSERT INTO @tablaAux(TipoDocumento, IdDocumento, NombreDoc, Activo, NombreUsuario, FechaCarga)
					SELECT	5, IdDocumento, NombreDocumento, doc.Activo, u.Nombre, doc.CreadoEl
					FROM	dbo.MM_PeticionOfertaADAdjunto doc
							INNER JOIN dbo.MM_SolicitudPedido solPed ON solPed.IdSolicitudPedido=doc.IdSolicitudPedido
							LEFT JOIN dbo.S_Usuario u ON u.IdUsuario=doc.CreadoPor
					WHERE	doc.IdSolicitudPedido=@IdSolicitudPedido AND doc.Activo=1
							AND	  ISNULL(solPed.IdEstatusEliminado, 0)=0

		INSERT INTO @tablaAux(TipoDocumento, IdDocumento, NombreDoc, Activo, NombreUsuario, FechaCarga)
					SELECT	6, Id, NombreDocumento, doc.Activo, u.Nombre, doc.CreadoEl
					FROM	dbo.MM_PeticionOfertaMercadeoAdjunto doc
							INNER JOIN dbo.MM_SolicitudPedido solPed ON solPed.IdSolicitudPedido=doc.IdSolicitudPedido
							LEFT JOIN dbo.S_Usuario u ON u.IdUsuario=doc.CreadoPor
					WHERE	doc.IdSolicitudPedido=@IdSolicitudPedido AND doc.Activo=1
							AND	  ISNULL(solPed.IdEstatusEliminado, 0)=0
		
	

		INSERT INTO @TablaAceptacion
		(TipoDocumento, IdDocumento, NombreDoc, Activo, Descripcion, AceptacionDocumento, IdAceptacionPedido ,
		 NombreUsuario , FechaCarga)
					SELECT	7, AD.IdDocumento, AD.NombreDocumento, AD.Activo ,
							'(' +LTRIM(apd.Cantidad)+') - '+pod.MaterialCotizadoTextoL+' - '+pod.UnidadProveedor AS descripcion ,
							CONVERT(NVARCHAR(100), AP.IdAceptacionPedido)+' - '+AP.Comentario AS AceptacionDocumento ,
							AP.IdAceptacionPedido, u.Nombre, doc.CreadoEl
					FROM	dbo.MM_AceptacionDocumento AS AD
							INNER JOIN dbo.MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido=AD.IdAceptacionDocumento
							LEFT JOIN dbo.MM_PedidoDetalle pd ON pd.IdPedido=AP.IdPedido
							INNER JOIN dbo.MM_AceptacionPedidoDetalle apd ON apd.IdAceptacionPedido=AP.IdAceptacionPedido
																			 AND  apd.IdPedidoDetalle=pd.IdPedidoDetalle
							INNER JOIN dbo.MM_PeticionOfertaDetalle pod ON pod.IdPeticionOfertaDetalle=pd.IdPeticionOfertaDetalle
							LEFT JOIN dbo.S_Documento_S3 doc ON doc.IdDocumento=AD.IdDocumento
							LEFT JOIN dbo.S_Usuario u ON u.IdUsuario=doc.CreadoPor
					WHERE	AP.IdAceptacionPedido IN(SELECT AP.IdAceptacionPedido
													 FROM	MM_AceptacionPedido AS AP
															INNER JOIN MM_Pedido AS MP ON MP.IdPedido=AP.IdPedido
													 WHERE	MP.IdSolicitudPedido=@IdSolicitudPedido)
							AND AD.IdDocumento IS NOT NULL AND	AD.Activo=1 AND ISNULL(AP.IdEstatusEliminado, 0)=0

				INSERT INTO @tablaAux
				(TipoDocumento, IdDocumento, NombreDoc, Activo, Descripcion, AceptacionDocumento, IdAceptacionPedido ,
					NombreUsuario , FechaCarga)
						SELECT 7, IdDocumento, NombreDoc, Activo , STUFF (
					 (	  SELECT	CAST(', ' AS VARCHAR(MAX)) + CONVERT ( NVARCHAR(MAX), Descripcion )
					  FROM		@TablaAceptacion ap
					  WHERE ap.IdAceptacionPedido = ap2.IdAceptacionPedido
					  GROUP BY	IdAceptacionPedido, Descripcion
					  FOR XML PATH ( '' )), 1, 1, '' )	,
					   AceptacionDocumento ,
							IdAceptacionPedido, NombreUsuario, FechaCarga
					  FROM @TablaAceptacion ap2
					  GROUP BY IdAceptacionPedido, IdDocumento, NombreDoc, Activo,AceptacionDocumento ,
							IdAceptacionPedido, NombreUsuario, FechaCarga
                              

		--INSERT INTO @tablaAux
		--	( TipoDocumento, IdDocumento, NombreDoc, Activo, NombreUsuario, FechaCarga )
		--SELECT		10, doc.Id, doc.NombreDocumento, doc.Activo, u.Nombre, doc.CreadoEl
		--FROM		dbo.DocumentosPedido doc
		--LEFT JOIN	dbo.S_Usuario u
		--	ON doc.CreadoPor = u.IdUsuario
		--WHERE		doc.Activo = 1

		INSERT INTO @tablaAux(TipoDocumento, IdDocumento, NombreDoc, Activo, NombreUsuario, FechaCarga)
					SELECT	10, doc.Id, doc.NombreDocumento, doc.Activo, u.Nombre, doc.CreadoEl
					FROM	dbo.DocumentosPedido doc
							LEFT JOIN dbo.MM_Pedido P ON P.IdPedido=doc.IdPedido
							LEFT JOIN dbo.S_Usuario u ON doc.CreadoPor=u.IdUsuario
					WHERE	doc.Activo=1 AND P.IdSolicitudPedido=@IdSolicitudPedido

		INSERT INTO @tablaAux(TipoDocumento, IdDocumento, NombreDoc, Activo, NombreUsuario, FechaCarga)
					SELECT	11, doc.IdDocumento, doc.NombreDocumento, 1, u.Nombre, doc.CreadoEl
					FROM	dbo.PCMDocumentoAdjunto doc
							INNER JOIN dbo.S_Usuario u ON doc.CreadoPor=u.IdUsuario
					WHERE	doc.IdSolicitucPedido=@IdSolicitudPedido AND doc.Activo=1

		SELECT *  FROM @tablaAux
	END

