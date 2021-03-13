create PROC [dbo].[p_SC_CargaInicial]  
    @pIdContratista INT,  
    @pIdContrato INT,  
    @pCreadoPor INT,  
    @pError VARCHAR(2540) OUT  
   
AS  
DECLARE @i INT = 0,  
        @idMaestro INT = 0,  
        @idMaterial INT = 0,  
        @idSCMaterial INT = 0,  
        @IdSubContratoPresupuesto INT = 0;  
  
  
  
BEGIN TRY  
  
    BEGIN TRAN;  
  
 set dateformat dmy  
  
    SELECT @i = MIN(IdSCDetalle)  
    FROM SC_Importacion  
    WHERE IdMaterial IS NULL;  
  
    DECLARE @idsubcontrato INT;  
  
    UPDATE SC_Importacion  
    SET RFCContratista = RTRIM(LTRIM(RFCContratista)),  
        RFCProveedor = RTRIM(LTRIM(RFCProveedor)),  
        IdMaterial = NULL;  
  
    WHILE @i IS NOT NULL  
    BEGIN  
  
        SET @idMaestro = 0;  
  
        IF EXISTS  
        (  
            SELECT 1  
            FROM SC_Importacion  
            WHERE IdSCDetalle = @i  
                  AND IdMaterial IS NULL  
        )  
        BEGIN  
  
            INSERT INTO Petrovendor..MM_Maestro
  
            (  
            /*IdMaestro,*/  
                IdTipoCatalogoMaestro,  
                IdSubFamilia,  
                TextoCorto,  
                TextoLargo,  
                IdMoneda,  
                IdTipoMaterial, 
				Prc,  
                IsActivo,  
                IsEliminado,  
                CreadoPor,  
                CreadoEn,  
                ModificadoPor,  
                ModificadoEn,  
                IdUnidadPreterminada,  
                IdUnidad_1,  
                IdUnidad_2,  
                IdUnidad_3  
            )  
            SELECT 1,  
                   NULL,  
                   DescripcionPartida,  
                   DescripcionPartida,  
                   m.IdMoneda,
					NULL,  
                   NULL,  
                   1,  
                   0,  
                   NULL,  
                   NULL,  
                   NULL,  
                   NULL,  
                   ISNULL(u.IdUnidad, 10011 /*SERVICIO*/),  
                   NULL,  
                   NULL,  
                   NULL  
            FROM SC_Importacion i  
                LEFT JOIN Petrovendor..PV_TipoMoneda m  
                    ON UPPER(m.TipoMonedaCorto) COLLATE SQL_Latin1_General_CP1_CI_AS = UPPER(i.Moneda) COLLATE SQL_Latin1_General_CP1_CI_AS  
                LEFT JOIN Petrovendor..PV_MM_MaterialUnidad u  
                    ON (  
                           UPPER(u.UMB) COLLATE SQL_Latin1_General_CP1_CI_AS = RTRIM(UPPER(i.UnidadMedida)) COLLATE SQL_Latin1_General_CP1_CI_AS  
                           OR UPPER(i.UnidadMedida) COLLATE SQL_Latin1_General_CP1_CI_AS LIKE '%'  
                                                                                              + RTRIM(UPPER(u.Unidad))  
                                                                                              + '%' COLLATE SQL_Latin1_General_CP1_CI_AS  
                       )  
            WHERE IdSCDetalle = @i;  
  
            SET @idMaestro = SCOPE_IDENTITY();  
  
  
     
            INSERT INTO Petrovendor..MM_Material  
            (  
                IdProveedor,  
                IdUnidad,  
                DescripcionCorta,  
                DescripcionLarga,  
                Consumible

,  
                Inventariable,  
                TiempoEntregaEstimadoDias,  
                Marca,  
                IsPublico,  
                Imagen,  
                FechaAlta,  
                Activo,  
                IsEliminado,  
				IdMaestro,  
                IsClasificionMaestro,  
                IdTipoProveedor,  
                IdTipoCatalogoMaestro  
            )  
            SELECT prov.IdProveedor,  
                   mm.IdUnidadPreterminada, 
					mm.TextoLargo,  
                   mm.TextoLargo,  
                   0,  
                   1,  
                   0,  
                 NULL,  
                   1,  
                   NULL,  
                   GETDATE(),  
					1,  
        
           0,  
                   mm.IdMaestro,  
                   1,  
                   2,  
                   mm.IdTipoCatalogoMaestro  
            FROM Petrovendor..MM_Maestro mm  
                INNER JOIN SC_Importacion i

			ON i.IdSCDetalle = @i  
                INNER JOIN Petrovendor..S_Proveedor prov  
                    ON prov.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = i.RFCProveedor COLLATE SQL_Latin1_General_CP1_CI_AS  
            WHERE mm.IdMaestro = @idMaestro; 

 
  
            SET @idMaterial = SCOPE_IDENTITY();  
  
  
  
  
            UPDATE SC_Importacion  
            SET IdMaterial = @idMaterial  
            WHERE IdSCDetalle = @i;  
  
  
        END;  
  
        SELECT @i = MIN(IdSCDetalle) 
		FROM SC_Importacion  
        WHERE IdMaterial IS NULL  
              AND IdSCDetalle > @i;  
  
    END;  
  
  
    DECLARE @pedidoC VARCHAR(50);  
  
    SELECT @pedidoC = MIN(NumeroPedido)  
    FROM SC_Importacion  
    WHERE IdSubcontrato IS NULL; 

 
  
  
    WHILE @pedidoC IS NOT NULL  
    BEGIN  
  
	
  
        SELECT @idsubcontrato = MAX(IdSubContrato)  
        FROM SC_SubContrato  
        WHERE RTRIM(NumeroSubContrato) = RTRIM(@pedidoC)  
              AND IsActivo = 1  
              AND ISNULL(IsEliminado, 0) = 0  
			  AND IdContrato = @pIdContrato

  
        IF ISNULL(@idsubcontrato, 0) = 0  
        BEGIN  
  
            SELECT @idsubcontrato = ISNULL(MAX(IdSubContrato), 0) + 1  
            FROM SC_SubContrato;  
  
        END;  
  
  
        INSERT INTO SC_SubContrato  
        (  
            IdSubContrato,  
            IdSubContratista,  
            IdContratista,  
            NumeroSubContrato,  
            CreadoPor,  
            CreadoEl,  
            ModificadoPor,  
            ModificadoEl,  
			IsActivo,  
            IsEliminado,  
            Objeto,  
            IdPedido,  
            PrefijoOT,  
            IdContrato,  
            IdMoneda,  
            IdTipoPedido
        )  
        SELECT @idsubcontrato,  
               prov.IdSubcontratista,  
               con.IdContratista,  
               CAST(tmp.NumeroPedido AS VARCHAR),  
               @pCreadoPor,  
               GETDATE(),  
               NULL,  
               NULL,  
               1,  
               0,  
               tmp.Descripcion,  
               NULL,  
               'OT-' + CASE  
                           WHEN LEN(tmp.NumeroPedido) <= 5 THEN  
                               tmp.NumeroPedido  
                           ELSE  
                 

              SUBSTRING(tmp.NumeroPedido, LEN(tmp.NumeroPedido) - 4, LEN(tmp.NumeroPedido))  
                       END,  
               MAX(c.IdContrato),  
               m.IdMoneda,  
               tmp.IdTipoPedido
        FROM SC_Importacion tmp  

            INNER JOIN PV_Subcontratista prov  
                ON prov.RFC = tmp.RFCProveedor  AND
				prov.IsActivo = 1
            INNER JOIN CO_Contratista con  
                ON con.IdContratista = @pIdContratista  
            INNER JOIN CO_Contrato c  
                ON	c.IdContrato = @pIdContrato  
            LEFT JOIN Petrovendor..PV_TipoMoneda m  
                ON UPPER(m.TipoMonedaCorto) COLLATE SQL_Latin1_General_CP1_CI_AS = UPPER(tmp.Moneda) COLLATE SQL_Latin1_General_CP1_CI_AS  
        WHERE NOT EXISTS     	
		(  
							SELECT 1  
							FROM SC_SubContrato  
							WHERE NumeroSubContrato = CAST(tmp.NumeroPedido AS VARCHAR)  
								  AND IdContratista = con.IdContratista  
								  AND IsActivo = 1  
								  AND ISNULL(IsEliminado, 0) = 0  
		)  
        AND tmp.NumeroPedido = @pedidoC  
        GROUP BY tmp.NumeroPedido,  
                 prov.IdSubcontratista,  
                 con.IdContratista,  
                 tmp.IdSCCarga,                
				 tmp.RFCProveedor,  
                 m.IdMoneda,  
                 tmp.IdTipoPedido,  
				 tmp.Descripcion;  
  
        SELECT @idSCMaterial = ISNULL(MAX(IdSCMaterial), 0)  
        FROM [SC_Materiales];  
  
        INSERT INTO [dbo].[SC_Materiales]  
        (  
            IdSCMaterial,  
            IdSubContrato,  
            Concepto,  
            IdMaestro,  
            IdUnidad,  
            Cantidad,  
            PrecioUnitario,  
            Importe,  
            Descripcion,
  
            DescripcionCorta,  
            CreadoPor,  
            CreadoEl,  
            ModificadoPor,  
            ModificadoEl,  
            IdServicio  
        )  
        SELECT ROW_NUMBER() OVER (ORDER BY IdSCDetalle ASC) + @idSCMaterial, 

 
               @idsubcontrato,  
               I.Partida,  
               I.IdMaterial,  
               ISNULL(mat.IdUnidad, 10011),  
               I.Cantidad,  
               I.PrecioUnitario,  
               ISNULL(Cantidad, 0) * ISNULL(I.PrecioUnitario, 0),  
               CAST(mat.DescripcionLarga AS VARCHAR(510)),  
               CAST(mat.DescripcionCorta AS VARCHAR(250)),  
               @pCreadoPor,  
               GETDATE(),  
               NULL,  
               NULL,             
			NULL  
        FROM SC_Importacion I  
            INNER JOIN Petrovendor..MM_Material mat  
                ON mat.IdMaterial = I.IdMaterial  
            INNER JOIN SC_SubContrato sc  
                ON sc.IdSubContrato = @idsubcontrato  
        WHERE I.NumeroPedido = @pedidoC  
              AND ISNULL(@idsubcontrato, 0) > 0  
              AND NOT EXISTS  
				(  
					SELECT 1  
					FROM [SC_Materiales] st1  
					WHERE st1.IdSubContrato = @idsubcontrato  
             
					AND st1.Concepto = I.Partida  
				);  
  
  
        SELECT @IdSubContratoPresupuesto = ISNULL(MAX(IdSubContratoPresupuesto), 0)  
        FROM SC_Presupuesto;  
  
        INSERT INTO SC_Presupuesto  
        (  
            IdSubContratoPresupuesto,  
            IdSubContrato,  
            IdPresupuesto,  
            CreadoPor,  
            CreadoEl  
        )  
        SELECT ROW_NUMBER() OVER (ORDER BY sc.IdSubContrato ASC) + @IdSubContratoPresupuesto,  
               sc.IdSubContrato,
  
               pre.IdPresupuesto,  
               1,  
               GETDATE()  
        FROM SC_SubContrato sc  
            INNER JOIN CO_Contrato con  
                ON con.IdContrato = @pIdContrato  
            INNER JOIN CO_PeriodoContrato pc

  
                ON pc.IdContrato = con.IdContrato  
            INNER JOIN CO_ProgramaActividad pa  
                ON pa.IdPeriodoContrato = pc.IdPeriodo  
            INNER JOIN CO_Presupuesto pre  
                ON pre.IdProgramaActividad = pa.IdProgramaActividad  
        WHERE sc.IdSubContrato = @idsubcontrato  
              AND NOT EXISTS  
        (  
            SELECT 1  
            FROM SC_Presupuesto s1  
            WHERE s1.IdPresupuesto = pre.IdPresupuesto  
                  AND s1.IdSubContrato = sc.IdSubContrato  
        )  
        GROUP BY sc.IdSubContrato,  
                 sc.IdSubContrato,  
                 pre.IdPresupuesto;  
  
        EXEC [dbo].[p_SC_Materiales_Gen] @idsubcontrato, '';  
  
        UPDATE SC_Importacion  
        SET IdSubcontrato = @idsubcontrato  
        WHERE IdSubcontrato IS NULL  
              AND NumeroPedido = @pedidoC;  
  
        SELECT @pedidoC = MIN(NumeroPedido)  
        FROM SC_Importacion  
        WHERE IdSubcontrato IS NULL
     
         AND NumeroPedido > @pedidoC;  
  
    END;  
  
    COMMIT TRAN;  
  
END TRY  
BEGIN CATCH  
  
    ROLLBACK TRAN;  
    SET @pError = ERROR_MESSAGE()+'|LINEA:'+cast(ERROR_LINE() as varchar);  
  
 select @pError;  
  
   
END CATCH;
