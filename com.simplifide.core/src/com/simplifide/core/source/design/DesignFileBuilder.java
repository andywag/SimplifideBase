/*******************************************************************************
 * Copyright (c) 1995/2004 Simplifide, LLC.
 * All Right Reserved.
 ******************************************************************************/
package com.simplifide.core.source.design;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.io.StringReader;
import java.net.URI;
import java.util.ArrayList;
import java.util.List;

import org.eclipse.core.resources.IMarker;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspaceRunnable;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.OperationCanceledException;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IRegion;

import com.simplifide.base.basic.struct.NodePosition;
import com.simplifide.base.core.doc.ToDoObject;
import com.simplifide.base.core.error.ErrorEnableHolder;
import com.simplifide.base.core.error.err.TopError;
import com.simplifide.base.core.module.SuperModule;
import com.simplifide.base.core.project.BuildInterface;
import com.simplifide.base.core.project.CoreProjectBasic;
import com.simplifide.base.core.project.CoreProjectSuite;
import com.simplifide.base.core.reference.ReferenceItem;
import com.simplifide.base.core.reference.ReferenceLocation;
import com.simplifide.base.core.reference.ReferenceUsage;
import com.simplifide.base.sourcefile.antlr.ParseDescriptor;
import com.simplifide.base.sourcefile.antlr.parse.EditorFindItem;
import com.simplifide.base.sourcefile.antlr.parse.ParserTop;
import com.simplifide.core.CoreActivator;
import com.simplifide.core.HardwareLog;
import com.simplifide.core.baseeditor.source.GeneralFileBuilder;
import com.simplifide.core.error.ErrorWrapper;
import com.simplifide.core.project.EclipseBaseProject;
import com.simplifide.core.project.EclipseDummyProject;
import com.simplifide.core.project.EclipseDummySuite;
import com.simplifide.core.project.EclipseSuite;
import com.simplifide.core.pythonext.console.BuildConsole;
import com.simplifide.core.ui.preference.PreferenceConstants;

public abstract class DesignFileBuilder extends GeneralFileBuilder{

	public static boolean OVERRIDESIZE = false;
	/** Parse Descriptor which contains the information required for this build */
	private ParseDescriptor parseDescriptor;	
	/** Design File which this object supports */
	
	
	
	public DesignFileBuilder(DesignFile designFile) {
		super(designFile);
		this.createParseDescriptor();
	}
	
	public void closeFile() {
		this.parseDescriptor.clean();
		
	}
	
	public void deleteObject() {
		this.getSuperModule().getObject().deleteObject();
	}
	
	public abstract FileTemplateHandler createTemplateHandler(DesignFile dfile);
	public abstract ParseDescriptor createParseDescriptor(String name, URI uri);
	
	
	public void expandTemplates() {
		// Reset the python script engine first (Temporary)
		//PythonInterpreterHolder.getInstance().cleanScriptDirectory();
		//PythonStartup.getDefault().cleanUp();
		
		/** Method to expand templates in the design file */
		FileTemplateHandler handler = this.createTemplateHandler(this.getDesignFile());
		handler.expandTemplates();
		
		if (!this.getDesignFile().isOpened()) {	
			this.getParseDescriptor().clean();
		}
		
		
	}
	
	/** Attaches Project to the design file. The project is used for
	 *  searching
	 * @param project
	 */
	public void attachProject(EclipseBaseProject project) {
		ReferenceItem<? extends CoreProjectSuite> suiteRef = project.getSuiteReference();
		ReferenceLocation loc = new ReferenceLocation(this.getDesignFile().getUri(), -1,0,0);
		this.getParseDescriptor().attachProject(suiteRef, project.createReferenceItem(), loc);
		//this.designFile.createBuilder();
	}

	private void createParseDescriptor() {
		ParseDescriptor desc = this.createParseDescriptor(this.getDesignFile().getname(),this.getDesignFile().getUri());  
		this.setParseDescriptor(desc);
		//EclipseDummySuite suite = new EclipseDummySuite();
		//ReferenceItem<EclipseSuite> suiteRef = suite.createReferenceItem();
		//EclipseDummyProject project = new EclipseDummyProject(suiteRef);
		//desc.setSuiteReference(suiteRef);
		//desc.setProjectReference(project.createReferenceItem());
		//ReferenceLocation location = new ReferenceLocation(this.getDesignFile().getUri(),0,0,0);
		//desc.setBaseLocation(location);

	}
	
        protected abstract ErrorWrapper createErrorWrapper(TopError error);
        /*
        public void addScalaMarkers(final List<InterfaceError> errors, final NodePosition pos) {
        	final String MarkerID = "com.simplifide.core.externalMarker";
        	final IResource resource = this.getDesignFile().getResource();
        	final IDocument doc = this.getDesignFile().getEditor().getDocument();
        	if (resource == null) return; // Case of File not in workspace
        	try {
        		ResourcesPlugin.getWorkspace().run(
        				new IWorkspaceRunnable() {
        					public void run(IProgressMonitor monitor) {
        						try {
        							resource.deleteMarkers(MarkerID, false, 0);
            						
            						for (InterfaceError object : errors) {
            							int line = object.getLine() + pos.getStartLine();
            							IRegion reg = doc.getLineInformation(line-1);
            							//ReferenceLocation loc = object.getLocation();
            							IMarker marker = resource.createMarker(MarkerID);
    									marker.setAttribute(IMarker.CHAR_START, reg.getOffset());
    	        						marker.setAttribute(IMarker.CHAR_END, reg.getOffset() + reg.getLength());
    	        						marker.setAttribute(IMarker.MESSAGE, object.getMessage());
    	        						
    	        						if (object.isError()) marker.setAttribute(IMarker.SEVERITY, IMarker.SEVERITY_ERROR);
    	        						else if (object.isWarning()) marker.setAttribute(IMarker.SEVERITY, IMarker.SEVERITY_WARNING);
    	        						else marker.setAttribute(IMarker.SEVERITY, IMarker.SEVERITY_INFO);
    	        						
    	        						marker.setAttribute(IMarker.LINE_NUMBER, line );
            						}
        						}
        						catch (CoreException e) {
    								HardwareLog.logError(e);
    							} catch (BadLocationException e) {
									HardwareLog.logError(e);
								}
        					}
        					
        				},null);
        	}
        	catch (CoreException e) {
        		HardwareLog.logError(e);
        	}
        }
        */
        private void addTaskMarkers(final ParseDescriptor desc) {
        	final String MarkerID = "org.eclipse.core.resources.taskmarker";
        	final IResource resource = this.getDesignFile().getResource();
        	if (resource == null) return; // Case of File not in workspace
        	try {
        		ResourcesPlugin.getWorkspace().run(
        				new IWorkspaceRunnable() {
        					public void run(IProgressMonitor monitor) {
        						try {
        							resource.deleteMarkers(MarkerID, false, 0);
            						List<ToDoObject> objects = desc.getStream().getTodoList();
            						for (ToDoObject object : objects) {
            							ReferenceLocation loc = object.getLocation();
            							IMarker marker = resource.createMarker(MarkerID);
    									marker.setAttribute(IMarker.CHAR_START, loc.getDocPosition());
    	        						marker.setAttribute(IMarker.CHAR_END, loc.getDocPosition() + loc.getLength());
    	        						marker.setAttribute(IMarker.MESSAGE, object.getDescription());
    	        						marker.setAttribute(IMarker.SEVERITY, IMarker.TASK);
    	        						marker.setAttribute(IMarker.LINE_NUMBER, loc.getLine());
            						}
        						}
        						catch (CoreException e) {
    								HardwareLog.logError(e);
    							}
        					}
        					
        				},null);
        	}
        	catch (CoreException e) {
        		HardwareLog.logError(e);
        	}
        	
        }
        
        private void addMarkers(final ParseDescriptor desc) {
        	final String MarkerID = CoreActivator.PLUGIN_ID + ".syntaxMarker";
        	final IResource resource = this.getDesignFile().getResource();
        	if (resource == null) return; // Case of File not in workspace
        	
        	
        	try {
        		ResourcesPlugin.getWorkspace().run(
        				new IWorkspaceRunnable() {
        					public void run(IProgressMonitor monitor) {

        						try {
        							
        							resource.deleteMarkers(MarkerID, false, 0);
        							

        						} catch (CoreException e) {
        							HardwareLog.logError(e);
        						}

        						if (desc != null) {
        							List<? extends TopError> errList = new ArrayList();
        							if (desc.getStream() != null) {
        								
        								errList = desc.getStream().createRealSyntaxErrorList(parseDescriptor.getBaseLocation());
        								
        							}
        							for (TopError error : errList) {
        								ErrorWrapper wrap = createErrorWrapper(error);
        								wrap.createError(resource,getDesignFile().getSourceLocation(),-1);
        							}
        							int index = 0;    
        							for (TopError error : desc.getErrorList()) {
        								ErrorWrapper wrap = createErrorWrapper(error);
        								wrap.createError(resource,getDesignFile().getSourceLocation(),index);
        								index++;
        								
        							}
        						}
        					}
        				},null);
        	} catch (CoreException e) {
        		HardwareLog.logError(e);
		}
		
		
		
	}
	
       
        private void updateResultsWithFile(List<ReferenceUsage> refList) {
            InputStream stream;
            int currentLine = 0;
            try {
                String currentText = "";
                BufferedReader reader;
                if (this.getDesignFile().getResource() == null) return;
                if (this.getDesignFile() instanceof DesignFileAlone) {
                	String ustr = this.getDesignFile().getEditor().getDocument().get();
                	StringReader read = new StringReader(ustr);
                	reader = new BufferedReader(read);
                }
                else {
                	 stream = this.getDesignFile().getFileContents();
                     reader = new BufferedReader(new InputStreamReader(stream));
                }
               
                if (refList == null) return;
                for (ReferenceUsage usage : refList) {
                    int usageLine = usage.getLocation().getLine();
                    while (usageLine > currentLine) {
                        currentText = reader.readLine().trim();
                        currentLine++;
                    }
                    if (currentLine == usageLine) {
                        usage.setText(currentText);
                    }
                }
                reader.close();
                
            } catch (IOException e) {
                HardwareLog.logError(e);
            }
            
            
        }
        
	/** Returns a list of object which reference this */
	public List<ReferenceUsage> findReferenceItems(EditorFindItem eitem) {
		this.parseDescriptor.setEditorFindItem(eitem);
		this.build(BuildInterface.BUILD_FIND_USAGES);
        List<ReferenceUsage> refList = this.parseDescriptor.getFindUsages();
        this.updateResultsWithFile(refList);
                
		return refList;
	}
	
	protected abstract String getPostFix(); 
    
    protected ErrorEnableHolder createErrorEnableHolder() {
		IPreferenceStore store = CoreActivator.getDefault().getPreferenceStore();
		ErrorEnableHolder holder = new ErrorEnableHolder();
		
		holder.errorSyntax = store.getBoolean(PreferenceConstants.ERROR_SYNTAX + this.getPostFix());
		holder.errorNotdefined = store.getBoolean(PreferenceConstants.ERROR_NOT_DEFINED + this.getPostFix());
		
		holder.warningLatch =  store.getBoolean(PreferenceConstants.WARNING_LATCH + this.getPostFix());
		holder.warningNotassigned =  store.getBoolean(PreferenceConstants.WARNING_NOT_ASSIGNED + this.getPostFix());
		holder.warningNotused =  store.getBoolean(PreferenceConstants.WARNING_NOT_USED + this.getPostFix());
		
		return holder;
		
	}
    
    private void postBuild() {
    	this.getDesignFile().getCompileInfo().setParentItemList(this.parseDescriptor.getModule().getParentList());
    	
    }
	
    public void build(int kind, IProgressMonitor monitor) {
    	if (monitor.isCanceled()) {
			throw new OperationCanceledException();
		}
    	this.build(kind);
    
    }
    

    private void updateParseDescriptor() {
    	
    	ReferenceItem<CoreProjectBasic> projR = this.getDesignFile().getProjectRef();
		
		if (projR != null && projR.getObject() != null && projR.getObject().getSuiteReference() != null) {
			this.getParseDescriptor().setProjectReference(projR);
			this.parseDescriptor.setSuiteReference(projR.getObject().getSuiteReference());

		}
    }
    
	public void build(int kind) {
		//if (this.checkOverLength())  
		this.updateParseDescriptor();
		
		InputStream stream = null;
		Reader reader = null;
		try {
			if (!this.getDesignFile().isOpened()) {
				stream = this.getDesignFile().getInputStream();
				if (stream == null) return;
				reader = new InputStreamReader(stream);
			}
			else {
				IDocument doc = this.getDesignFile().getEditor().getDocument();
				String str = doc.get();	
				reader = new StringReader(str);
			}
			
			this.build(kind,reader);
			if (reader != null) reader.close();
			if (stream != null) stream.close();
		} catch (IOException e) {
			HardwareLog.logError(e);
		}
		this.postBuild();
	}
	
	private void printBuilding(int kind) {
		String build = "Building Normal";
		if (kind == BuildInterface.BUILD_FILE_CONTEXT) build = "Building Context ";
		
		BuildConsole.getDefault().writeOutputMessage(build + this.getDesignFile().getname() + "\n");

	}
	
	public void build(int kind, Reader reader) {
		this.printBuilding(kind);
		/*if (this.designFile.tooLarge()) {
			HardwareLog.logInfo("Can't Compile " + this.designFile + " Due to Size");
			return;
		}*/
		if (kind == BuildInterface.BUILD_CLOSE_HDLDOC) {
             if (!this.getDesignFile().isOpened()) {
                 this.parseDescriptor.clean();
             }
        }
		try {
			// Clear the parent list to remove the dependencies from this object
			this.parseDescriptor.getModule().getParentList().clearList();
			
			this.parseDescriptor.setMode(kind);
			this.parseDescriptor.setErrorConstants(this.createErrorEnableHolder());
			
			if (this.parseDescriptor.getSuiteReference() == null) {
				EclipseDummySuite suite = EclipseDummySuite.getInstance();
				EclipseDummyProject project = EclipseDummyProject.getInstance(suite.createReferenceItem());
				ReferenceLocation location = new ReferenceLocation(this.getDesignFile().getUri(),0,0,0);
				this.parseDescriptor.attachProject(suite.createReferenceItem(),
						project.createReferenceItem(), location);
			}
			
			if (this.parseDescriptor.getProjectReference() == null || 
				this.getParseDescriptor().getProjectReference().getObject() == null) {
				ReferenceItem<EclipseSuite> suiteR = (ReferenceItem<EclipseSuite>) this.getParseDescriptor().getSuiteReference();
				EclipseDummyProject project = EclipseDummyProject.getInstance(suiteR);
				ReferenceLocation location = new ReferenceLocation(this.getDesignFile().getUri(),0,0,0);
				this.parseDescriptor.attachProject(suiteR.getObject().createReferenceItem(),
						project.createReferenceItem(), location);
			}
			
			ParserTop parser = getDesignFile().getParser();
			if (parser != null) {		
				parser.compositeBuild(reader, this.getParseDescriptor());
			
			}
			if (kind != BuildInterface.BUILD_FILE_CONTEXT) {
				this.addMarkers(this.getParseDescriptor());
				this.addTaskMarkers(this.getParseDescriptor());
				this.getDesignFile().fireChange();
			}
			if (kind == BuildInterface.BUILD_FILE_CLOSED && !this.getDesignFile().isOpened()) {
				this.getParseDescriptor().clean();
			}
		}
		catch (Exception e) {
			HardwareLog.logError("Critical Error Compiling" + this + this.getDesignFile(), e);
		}
		this.postBuild();

	}

	public DesignFile getDesignFile() {
		return (DesignFile) this.getGeneralFile();
	}
	
	public ReferenceItem<SuperModule> getSuperModule() {
		return this.getParseDescriptor().getModule().createReferenceItem();
	}

	public void setParseDescriptor(ParseDescriptor parseDescriptor) {
		this.parseDescriptor = parseDescriptor;
	}

	public ParseDescriptor getParseDescriptor() {
		return parseDescriptor;
	}


}
