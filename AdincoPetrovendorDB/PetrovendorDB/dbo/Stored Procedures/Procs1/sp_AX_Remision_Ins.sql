CREATE PROCEDURE [dbo].[sp_AX_Remision_Ins] --'','5156','5116',59,'49',45.3,'789'  
  
    --@IdRemision VARCHAR(max) out,  
    @IdOC VARCHAR(8000),  
    @RECID VARCHAR(MAX),  
    @DataAreaId VARCHAR(MAX),  
    @IdPedido INT,  
    @Item VARCHAR(MAX),  
    @Cantidad DECIMAL (20,2),  
    @Asiento VARCHAR(8000),  
    @IdRemisionCARSO VARCHAR(MAX)  
AS  
BEGIN  
    INSERT dbo.AX_RemisionLog  
    (  
        IdOC,  
        RECID,  
        DataAreaId,  
        IdPedido,  
        Item,  
        Cantidad,  
        Asiento,  
        fecharegistro,  
        idRemisionCARSO  
    )  
    VALUES  
    (@IdOC, @RECID, @DataAreaId, @IdPedido, @Item, @Cantidad, @Asiento, GETDATE(), @IdRemisionCARSO)  
  
  
    DECLARE @ERROR NVARCHAR(MAX) = N'DATO(S) FALTANTE(S): ';  
    DECLARE @ERRORDATO NVARCHAR(MAX) = N'';  
  
  
    IF ISNULL(@IdOC, '') = ''  
    BEGIN  
        IF @ERRORDATO <> ''  
        BEGIN  
            SET @ERRORDATO = @ERRORDATO + N', IdOC'  
        END  
        ELSE  
        BEGIN  
            SET @ERRORDATO = N'IdOC'  
        END;  
    END;  
  
  
    IF ISNULL(@RECID, '') = ''  
    BEGIN  
        IF @ERRORDATO <> ''  
        BEGIN  
            SET @ERRORDATO = @ERRORDATO + N', RECID'  
        END  
        ELSE  
        BEGIN  
            SET @ERRORDATO = N'RECID'  
        END;  
    END;  
  
  
    IF ISNULL(@DataAreaId, '') = ''  
    BEGIN  
        IF @ERRORDATO <> ''  
        BEGIN  
            SET @ERRORDATO = @ERRORDATO + N', DataAreaId'  
        END  
        ELSE  
        BEGIN  
            SET @ERRORDATO = N'DataAreaId'  
        END;  
    END;  
  
  
    IF ISNULL(@IdPedido, '') = ''  
    BEGIN  
        IF @ERRORDATO <> ''  
        BEGIN  
            SET @ERRORDATO = @ERRORDATO + N', IdPedido'  
        END  
        ELSE  
        BEGIN  
            SET @ERRORDATO = N'IdPedido'  
        END;  
    END;  
  
  
    IF ISNULL(@Item, '') = ''  
    BEGIN  
        IF @ERRORDATO <> ''  
        BEGIN  
            SET @ERRORDATO = @ERRORDATO + N', Item'  
        END  
        ELSE  
        BEGIN  
            SET @ERRORDATO = N'Item'  
        END;  
    END;  
  
  
    IF ISNULL(@Cantidad, 0) = 0  
    BEGIN  
        IF @ERRORDATO <> ''  
        BEGIN  
            SET @ERRORDATO = @ERRORDATO + N', Cantidad'  
        END  
        ELSE  
        BEGIN  
            SET @ERRORDATO = N'Cantidad'  
        END;  
    END;  
  
  
    IF ISNULL(@Asiento, '') = ''  
    BEGIN  
        IF @ERRORDATO <> ''  
        BEGIN  
            SET @ERRORDATO = @ERRORDATO + N', Asiento'  
        END  
        ELSE  
        BEGIN  
            SET @ERRORDATO = N'Asiento'  
        END;  
    END;  
  
  
    -- Se revisa si ya contiene carta de contenido  
    SELECT @ERRORDATO += dbo.FN_CarsoObtenerContieneCartaContenido(@IdOC, @Asiento, @DataAreaId, @RECID)  
  
  
    IF @ERRORDATO = ''  
    BEGIN  
        DECLARE @EXISTE_REMISION INT =  
                (  
                    SELECT COUNT(IdRemision)  
                    FROM dbo.AX_Remision  
                    WHERE IdOC = @IdOC  
                          AND RECID = @RECID  
                          AND DataAreaId = @DataAreaId  
                          AND Item = @Item  
                );  
  
  
        IF ISNULL(@EXISTE_REMISION, 0) > 0  
        BEGIN  
            DECLARE @Balance DECIMAL(20, 2),  
                    @IdRemision INT  
  
  
            SELECT @Balance = dbo.FN_CarsoObtenerRemanenteAceptacion(@RECID, @DataAreaId, @IdPedido, @IdOC, @Asiento)  
  
  
            SELECT @IdRemision = IdRemision  
            FROM dbo.AX_Remision  
            WHERE IdOC = @IdOC  
                  AND RECID = @RECID  
                  AND DataAreaId = @DataAreaId  
                  AND IdRemisionCARSO = @IdRemisionCARSO  
  
  
            UPDATE dbo.AX_Remision  
            SET IdOC = @IdOC,  
                RECID = @RECID,  
                DataAreaId = @DataAreaId,  
                IdPedido = @IdPedido,  
                Item = @Item,  
                Cantidad = @Cantidad,  
                Asiento = @Asiento,  
                IdRemisionCARSO = @IdRemisionCARSO,  
                FechaEdicion = GETDATE()  
            WHERE IdOC = @IdOC  
                  AND RECID = @RECID  
                  AND DataAreaId = @DataAreaId;  
  
    EXEC dbo.SP_GenerarRemisionCarso @IdOC = @IdOC,      -- varchar(8000)  
                                     @RecId = @RECID,     -- varchar(max)  
                                     @IdPedido = @IdPedido,   -- int  
                                     @DataAreaId = @DataAreaId, -- varchar(max)  
             @Asiento = @Asiento  
  
            SELECT CONCAT('Actualización Exitosa ', @Asiento, ' Balance: ', ISNULL(LTRIM(@Balance), '0')),  
                   @IdRemision,  
                   'UPDATE'  
            FROM dbo.AX_Remision  
            WHERE IdOC = @IdOC  
                  AND RECID = @RECID  
                  AND DataAreaId = @DataAreaId;  
        END;  
        ELSE  
        BEGIN  
            INSERT INTO AX_Remision  
            (  
                IdOC,  
                RECID,  
                DataAreaId,  
                IdPedido,  
                Item,  
                Cantidad,  
                Asiento,  
                fecharegistro,  
                IdRemisionCARSO  
            )  
            VALUES  
            (@IdOC, @RECID, @DataAreaId, @IdPedido, @Item, @Cantidad, @Asiento, GETDATE(), @IdRemisionCARSO);  
  
   EXEC dbo.SP_GenerarRemisionCarso @IdOC = @IdOC,      -- varchar(8000)  
                                     @RecId = @RECID,     -- varchar(max)  
                                     @IdPedido = @IdPedido,   -- int  
                                     @DataAreaId = @DataAreaId, -- varchar(max)  
             @Asiento = @Asiento  
  
            SELECT CONCAT('Recepción Exitosa ', @Asiento),  
                   SCOPE_IDENTITY(),  
                   'INSERT'  
        END;  
    END  
    ELSE  
    BEGIN  
        SELECT CONCAT('ERROR ',  @Item , ' - ', @ERROR, ' ', @ERRORDATO),  
               @Item + ' - ' + @ERROR + @ERRORDATO,  
               @ERRORDATO  
    END  
END;