IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'P_co_sap_importbitacoranotificacion'
    )
    DROP PROCEDURE P_co_sap_importbitacoranotificacion;
GO
--===========================================
--Modificador: Neri del Angel
--Fecha:       30 de Marzo del 20222
--Notas:       *Se ajustó filtrado de consultas principales 
--              por [CO_SAP_ImportBitacora].Id = @pId
--             *Se garegan NOLOCK a las consultas
--             *Se agrega Begin End al PROC
--             *Se agrega creacion de tabla temporal #tmpVendorBlank al principio del PROC
--===========================================
-- p_CO_SAP_ImportBitacoraNotificacion 7099,0
CREATE PROC [dbo].[P_co_sap_importbitacoranotificacion] @pId INT
AS
  BEGIN
      CREATE TABLE #tmpvendorblank
        (
			Id int identity primary key, 
           vendoridsap VARCHAR(max),
           vendorname  VARCHAR(max)
        );
	

      --S_Notificacion
      DECLARE @para             VARCHAR(500) = '',
              @asunto           VARCHAR(250),
              @mensaje          VARCHAR(max) = '',
              @de               VARCHAR(100) = '',
              @mensajeDetalle   VARCHAR(max) = '',
              @fechaUltimoEnvio DATETIME,
              @idContratista    INT


	  -- Para eliminar correos duplicados que pertenecen
	  SELECT @para = @para + ISNULL(LTRIM(RTRIM(co_sap_correosrespuesta.correo)), '') + ';' 
	  FROM co_sap_importbitacora  (nolock)
             INNER JOIN co_contrato c (nolock)
                     ON co_sap_importbitacora.id = @pId
                        AND c.idcontrato = co_sap_importbitacora.idcontrato
             INNER JOIN [dbo].[co_sap_correosrespuesta] (nolock)
                     ON co_sap_correosrespuesta.idcontratista = c.idcontratista
	  WHERE  ISNULL(co_sap_importbitacora.notificacionenviada, 0) = 0
	  GROUP BY ISNULL(LTRIM(RTRIM(co_sap_correosrespuesta.correo)), '')
	  
      SELECT TOP 1
             @asunto = Isnull(html.asunto, '')
                       + CONVERT(VARCHAR, inicio, 107) + ' '
                       + CONVERT(VARCHAR, inicio, 108),
             @de = cs.cuentaregistro,
             @mensaje = html.html,
             @fechaUltimoEnvio = imap.fechaultimoenvio,
             @idContratista = imap.idcontratista
      FROM   [dbo].[co_sap_importbitacora] b (nolock)
             INNER JOIN co_contrato c (nolock)
                     ON B.id = @pId
                        AND c.idcontrato = b.idcontrato
             INNER JOIN [dbo].[co_sap_correosrespuesta] res (nolock)
                     ON res.idcontratista = c.idcontratista
             INNER JOIN [s_correoservidor] cs (nolock)
                     ON cs.idcorreoservidor = 1
             INNER JOIN ta_correo html (nolock)
                     ON html.descripcion =
                        'NotificacionTareaMurphyImportacionSAP'
             INNER JOIN [co_sap_imapconfiguracion] imap (nolock)
                     ON imap.idcontratista = c.idcontratista
      WHERE  Isnull(b.notificacionenviada, 0) = 0


      -- Si la fecha de ultimo envío tiene menos de un día de diferencia, entonces salir del proceso
      IF ( Datediff(day, Isnull(@fechaUltimoEnvio, '20210101'), Getdate()) < 1 )
		BEGIN
			RETURN
		END

      IF Len(Isnull(@para, '')) = 0
		BEGIN
			RETURN
		END

      SELECT @mensaje = Replace(@mensaje, '{0}',
                               '<B>RESULT OF IMPORTATION SAP FILES</B><BR><BR>'
                                                 + 'CONTRACT:' + '<b>' +
                               c.numerocontrato
                                                 + '</b><br>' + 'START:' + '<b>'
                                                 + CONVERT(VARCHAR, inicio, 107)
                               +
                               ' '
                                                 + CONVERT(VARCHAR, inicio, 108)
                               +
                               '</b><br>'
                                                 + 'END:' + '<b>' + CONVERT(
                               VARCHAR,
                               fin, 107
                                                        ) + ' '
                                                 + CONVERT(VARCHAR, fin, 108) +
                               '</b><br><br>'
                                                 + CASE WHEN b.tieneerror = 1
                               THEN
                        '<p style="color:red">It ended with errors</p><br><br>'
                               ELSE
                               '' END)
      FROM   [dbo].[co_sap_importbitacora] b (nolock)
             INNER JOIN co_contrato c (nolock)
                     ON B.id = @pId
                        AND c.idcontrato = b.idcontrato
             INNER JOIN [dbo].[co_sap_correosrespuesta] res (nolock)
                     ON res.idcontratista = c.idcontratista
      WHERE  Isnull(b.notificacionenviada, 0) = 0

      SET @mensajeDetalle =
      '<table class="table"><tr><td><b>Step</b></td><td><b>Result</b></td></tr>'

      SELECT @mensajeDetalle = @mensajeDetalle + '<tr><td>'
                               + bd.nombrearchivo + '</td>' + '<td>' + CASE WHEN
                                      bd.tieneerror = 1 THEN
                               '<p style="color:red">' +
                                      bd.error +
                                      '</p><br><br>' ELSE
                                      '<p style="color:gren">OK</p><br><br>' END
                               + '</td></tr>'
      FROM   [dbo].[co_sap_importbitacora] b (nolock)
             INNER JOIN co_sap_importbitacora_detalle bd (nolock)
                     ON B.id = @pId
                        AND bd.idimportbitacora = b.id
      WHERE  Isnull(b.notificacionenviada, 0) = 0

      SET @mensajeDetalle = @mensajeDetalle + '</table>'
      SET @mensaje = Replace(@mensaje, '{1}', @mensajeDetalle)


      /***************Obtener vendors sin TAXID**************************/
      INSERT INTO #tmpvendorblank
                  (vendoridsap,
                   vendorname)
      SELECT v.vendoridsap,
             v.vendorname
      FROM   [co_sap_importbitacora] ib (nolock)
             INNER JOIN co_sapvendor v (nolock)
                     ON v.idcontrato = ib.idcontrato
                        AND Rtrim(Isnull(v.taxid, '')) = ''
      WHERE  id = @pId
      GROUP  BY v.vendoridsap,
                v.vendorname

      IF EXISTS (SELECT 1
                 FROM   #tmpvendorblank)
        BEGIN
            SET @mensajeDetalle =
            '<p style="color:red;">There are Vendors without TAXID</p><br>'
            SET @mensajeDetalle = @mensajeDetalle
                                  + '<table class="table"><tr><td><b>VendorID</b></td><td><b>Vendor Name</b></td></tr>'

			SELECT @mensajeDetalle = @mensajeDetalle + '<tr><td>'
									 + Cast(vendoridsap AS VARCHAR) + '</td>'
									 + '<td>' + vendorname + '</td></tr>'
			FROM   #tmpvendorblank

			SET @mensajeDetalle = @mensajeDetalle + '</table>'
			SET @mensaje = Replace(@mensaje, '{2}', @mensajeDetalle)
		END
		ELSE
		  BEGIN
			  SET @mensaje = Replace(@mensaje, '{2}', '')
		  END


			IF Isnull(@mensaje, '') <> ''
			  BEGIN

			  SELECT @para AS Para, @asunto AS Asunto, @mensaje AS Mensaje
				  
			  END

			--Marcar todo como enviado
			UPDATE [co_sap_importbitacora]
			SET    notificacionenviada = 1
			WHERE  Isnull(notificacionenviada, 0) = 0

			UPDATE [co_sap_imapconfiguracion]
			SET    fechaultimoenvio = Getdate()
			WHERE  idcontratista = @idContratista
	END 

