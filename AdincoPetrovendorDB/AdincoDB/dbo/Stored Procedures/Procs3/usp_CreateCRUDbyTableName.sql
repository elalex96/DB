/* ============================================================================
 Author:      Mitchell Guzman
 Create date: 2015-04-23
 Description: Creates the CRUD by Table Name

 Example:
 EXEC usp_CreateCRUDbyTableName @TableName = 'MarginRounder'
				History
 Date			Name				Comments
 ==============================================================================

 ==============================================================================*/
CREATE PROCEDURE [dbo].[usp_CreateCRUDbyTableName]
(
  @TableName VARCHAR(255)
)
AS
BEGIN
	--Get Insert Template
	DECLARE	@InputParams		VARCHAR(2000) = ''
			,@OutputParams		VARCHAR(2000) = ''
			,@InsertTemplate	VARCHAR(MAX)
			,@UpdateTemplate	VARCHAR(MAX)
			,@DeleteTemplate	VARCHAR(MAX)
			,@SetTemplate		VARCHAR(MAX)
			,@Columns			VARCHAR(MAX) = ''
			,@Columns1			VARCHAR(MAX) = ''
			,@User				VARCHAR(50) = ''
			,@CurDate			VARCHAR(20)
			,@ErrorMessage		VARCHAR(MAX)
			,@ErrorProcedure	VARCHAR(255)
			,@ErrorSeverity		INT
			,@ErrorState		INT
			,@ErrorLine			INT

	BEGIN TRY
		--Input params
		SELECT @User = REPLACE(SYSTEM_USER,'MIDDLE_EARTH\',''), 
                       @CurDate = CONVERT(VARCHAR(20),GETDATE(),100)

		SELECT  @InputParams = @InputParams + CHAR(9) + '@' + sc.name  + ' ' +  
		UPPER(st.name)  + ' ' + case when sc.user_type_id in (167,175,231,239) 
		then '(' + convert(varchar(20),CASE WHEN CONVERT(VARCHAR(6),sc.max_length) = '-1' 
		THEN 'MAX' ELSE CONVERT(VARCHAR(6),sc.max_length) END ) + ')' ELSE '' END + '' + 
		CASE WHEN sc.user_type_id in(59,60,106,108,122) THEN '(' + convert(varchar(5),sc.precision) + 
		',' + convert(varchar(5),sc.scale) + ')' ELSE '' END +  ',' + CHAR(10)  
		FROM sys.columns SC (NOLOCK) JOIN SYSOBJECTS SO(NOLOCK) ON SO.ID = SC.object_ID 
		JOIN sys.types ST (NOLOCK) ON ST.user_TYPE_ID = SC.user_TYPE_ID  WHERE so.type = 'U'  
		and so.name = @TableName and sc.is_identity = 0 order by Column_ID
		SELECT @InputParams = LEFT(@InputParams,LEN(@InputParams) - 2)

		SELECT @OutputParams = @OutputParams + CHAR(9)  + sc.name  + ' ' +  UPPER(st.name)  + 
		' ' + case when sc.user_type_id in (167,175,231,239) 
        then '(' + convert(varchar(20),sc.max_length) + ')' 
		ELSE '' END + '' + CASE WHEN sc.user_type_id in(59,60,106,108,122) THEN '(' + 
		convert(varchar(5),sc.precision) + ',' + convert(varchar(5),sc.scale) + ')' ELSE '' 
		END +  ',' + CHAR(10)  FROM sys.columns SC (NOLOCK) JOIN SYSOBJECTS SO(NOLOCK) 
		ON SO.ID = SC.object_ID JOIN sys.types ST (NOLOCK) ON ST.user_TYPE_ID = SC.user_TYPE_ID  
		WHERE so.type = 'U'  and so.name = @TableName and sc.is_identity = 0 order by Column_ID
		SELECT @OutputParams = LEFT(@OutputParams,LEN(@OutputParams) - 2)

		SELECT @Columns = @Columns + CHAR(9) +  SC.NAME + ',' + CHAR(10) + CHAR(9) + CHAR(9)
		FROM SYS.OBJECTS SO (NOLOCK)
		JOIN SYS.COLUMNS SC (NOLOCK) ON SC.object_id = SO.object_id
		WHERE SO.NAME = @TableName
		 AND sc.is_identity = 0
		 ORDER BY SC.NAME

		SET @Columns = LEFT(@Columns,LEN(@Columns) - 4)

		SELECT @Columns1 = @Columns1 + CHAR(9) + '@' +  SC.NAME + ',' + CHAR(10)+ CHAR(9) + CHAR(9)
		FROM SYS.OBJECTS SO (NOLOCK)
		JOIN SYS.COLUMNS SC (NOLOCK) ON SC.object_id = SO.object_id
		WHERE SO.NAME = @TableName
		 AND sc.is_identity = 0
		ORDER BY SC.NAME

		SET @Columns1 = LEFT(@Columns1,LEN(@Columns1) - 4)
		---------------------------------------
		---Insert
		---------------------------------------
		SELECT @InsertTemplate = Template
		FROM ProcedureTemplate t (NOLOCK)
		WHERE TemplateName = 'Insert'

		SET @InsertTemplate = REPLACE(@InsertTemplate,'~N',@TableName)
		SET @InsertTemplate = REPLACE(@InsertTemplate,'~U',@User)
		SET @InsertTemplate = REPLACE(@InsertTemplate,'~I',@InputParams)
		SET @InsertTemplate = REPLACE(@InsertTemplate,'~C',@Columns)
		SET @InsertTemplate = REPLACE(@InsertTemplate,'~V',@Columns1)
		SET @InsertTemplate = REPLACE(@InsertTemplate,'~D',@CurDate)

		SELECT @InsertTemplate

		------------------------------------
		---Update
		------------------------------------
		SELECT @UpdateTemplate = Template
		FROM ProcedureTemplate t (NOLOCK)
		WHERE TemplateName = 'Update'

		SET @Columns1 = ''

		SELECT @Columns1 = @Columns1 + CHAR(9) + SC.NAME + ' = ' + '@' +  
		SC.NAME + ',' + CHAR(10)+ CHAR(9) + CHAR(9)+ CHAR(9)
		FROM SYS.OBJECTS SO (NOLOCK)
		JOIN SYS.COLUMNS SC (NOLOCK) ON SC.object_id = SO.object_id
		WHERE SO.NAME = @TableName
		 AND sc.is_identity = 0
		ORDER BY SC.NAME

		SET @Columns1 = LEFT(@Columns1,LEN(@Columns1) - 5)

		SET @UpdateTemplate = REPLACE(@UpdateTemplate,'~N',@TableName)
		SET @UpdateTemplate = REPLACE(@UpdateTemplate,'~U',@User)
		SET @UpdateTemplate = REPLACE(@UpdateTemplate,'~I',@InputParams)
		SET @UpdateTemplate = REPLACE(@UpdateTemplate,'~C',@Columns1)
		SET @UpdateTemplate = REPLACE(@UpdateTemplate,'~D',@CurDate)

		SELECT @UpdateTemplate

		------------------------------------
		---DELETE
		------------------------------------
		SELECT @DeleteTemplate = Template
		FROM ProcedureTemplate t (NOLOCK)
		WHERE TemplateName = 'Delete'

		SET @DeleteTemplate = REPLACE(@DeleteTemplate,'~N',@TableName)
		SET @DeleteTemplate = REPLACE(@DeleteTemplate,'~U',@User)
		SET @DeleteTemplate = REPLACE(@DeleteTemplate,'~D',@CurDate)

		SELECT @DeleteTemplate

		------------------------------------
		---SET
		------------------------------------
		SELECT @SetTemplate = Template
		FROM ProcedureTemplate t (NOLOCK)
		WHERE TemplateName = 'Set'

		SET @InputParams = ''
		SELECT  @InputParams = @InputParams + CHAR(9) + '@' + sc.name  + ' ' +  
		UPPER(st.name)  + ' ' + case when sc.user_type_id in (167,175,231,239) 
		then '(' + convert(varchar(20),CASE WHEN CONVERT(VARCHAR(20),sc.max_length) = '-1' 
		THEN 'MAX' ELSE CONVERT(VARCHAR(20),sc.max_length) END) + ')' ELSE '' END + '' + CASE 
		WHEN sc.user_type_id in(59,60,106,108,122) THEN '(' + convert(varchar(5),sc.precision) + ',' + 
		convert(varchar(5),sc.scale) + ')' ELSE '' END +  CHAR(9) + ' = NULL,' + CHAR(10)    
		FROM sys.columns SC (NOLOCK) JOIN SYSOBJECTS SO(NOLOCK) ON SO.ID = 
		SC.object_ID JOIN sys.types ST (NOLOCK) ON ST.user_TYPE_ID = SC.user_TYPE_ID  
		WHERE so.type = 'U'  and so.name = @TableName and sc.is_identity = 0 order by Column_ID
		SELECT @InputParams = LEFT(@InputParams,LEN(@InputParams) - 2)


		SET @Columns = ''
		SELECT @Columns = @Columns + CHAR(9) +  SC.NAME + ',' + CHAR(10) + CHAR(9) + CHAR(9) + CHAR(9)
		FROM SYS.OBJECTS SO (NOLOCK)
		JOIN SYS.COLUMNS SC (NOLOCK) ON SC.object_id = SO.object_id
		WHERE SO.NAME = @TableName
		ORDER BY SC.name
		 --AND sc.is_identity = 0

		SET @Columns1 = ''
		SELECT @Columns1 = @Columns1 + CHAR(9) +  '(@' + SC.NAME + ' IS NULL OR ' + 
		SC.NAME + ' =  @' + SC.NAME + ')' + CHAR(10)  + CHAR(9) + CHAR(9)  + ' AND'
		FROM SYS.OBJECTS SO (NOLOCK)
		JOIN SYS.COLUMNS SC (NOLOCK) ON SC.object_id = SO.object_id
		WHERE SO.NAME = @TableName
		ORDER BY SC.name

		IF RIGHT(@Columns1,3) = 'AND'
		  BEGIN
			SET @Columns1 = LEFT(@Columns1,LEN(@Columns1) - 3)
		  END
		SET @Columns = LEFT(@Columns,LEN(@Columns) - 5)

		SET @SetTemplate = REPLACE(@SetTemplate,'~N',@TableName)
		SET @SetTemplate = REPLACE(@SetTemplate,'~C',@Columns)
		SET @SetTemplate = REPLACE(@SetTemplate,'~U',@User)
		SET @SetTemplate = REPLACE(@SetTemplate,'~I',@InputParams)
		SET @SetTemplate = REPLACE(@SetTemplate,'~V',@Columns1)
		SET @SetTemplate = REPLACE(@SetTemplate,'~D',@CurDate)

		SELECT @SetTemplate
	 END TRY
	 BEGIN CATCH

         SELECT  @ErrorMessage		= ERROR_MESSAGE()
				,@ErrorSeverity		= ERROR_SEVERITY()
				,@ErrorProcedure	= ERROR_PROCEDURE()
				,@ErrorState		= ERROR_STATE()
				,@ErrorLine			= ERROR_LINE()

		SET @ErrorMessage = 'Procedure: ' + @ErrorProcedure + ' ' + 
		@ErrorMessage + ' Line: ' + CONVERT(VARCHAR(6),@ErrorLine)

        RAISERROR ( @ErrorMessage, @ErrorSeverity, @ErrorState)

    END CATCH
	END