// 
// -------------------------------------------------------------
//    Copyright 2004-2009 Synopsys, Inc.
//    All Rights Reserved Worldwide
// 
//    Licensed under the Apache License, Version 2.0 (the
//    "License"); you may not use this file except in
//    compliance with the License.  You may obtain a copy of
//    the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
//    Unless required by applicable law or agreed to in
//    writing, software distributed under the License is
//    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//    CONDITIONS OF ANY KIND, either express or implied.  See
//    the License for the specific language governing
//    permissions and limitations under the License.
// -------------------------------------------------------------
// 


`ifdef ETH_USE_COMPOSITION
// Example 4-40
class eth_vlan_data;
   rand bit [ 2:0] user_priority;
   rand bit        cfi;
   rand bit [11:0] id;
endclass: eth_vlan_data
`endif


// Example 4-14
// Example 4-28
// Example 4-32
class eth_frame extends vmm_data;

   // Example 4-33
   static vmm_log log = new("eth_frame", "class");
   static eth_utils utils = new;

   // Example 4-36
   vmm_data context_data;

   // Example 4-38
   // Example 4-39       
   // A frame can either be tagged, untagged or be a control frame
   typedef enum {UNTAGGED, TAGGED, CONTROL} frame_formats_e;
   rand frame_formats_e format;

   rand bit [47:0] dst;
   rand bit [47:0] src;
`ifdef ETH_USE_COMPOSITION
   // Example 4-40
   rand eth_vlan_data vlan;
`else   
   rand bit [ 2:0] user_priority;  // if TAGGED
   rand bit        cfi;            // if TAGGED
   rand bit [11:0] vlan_id;        // if TAGGED
`endif
   
   // Example 4-34
   rand bit [15:0] len_typ;
   rand bit [15:0] opcode;      // if CONTROL
   rand bit [15:0] pause_time;  // if opcode == PAUSE

   rand int data_size;
   rand bit [ 7:0] data[];
   // Example 4-37
   rand bit [31:0] fcs;

   //
   // Opcodes
   //
   typedef enum bit [15:0] {PAUSE = 16'h0001} opcodes_e;
  
   //
   // Faclitate expressing constraints
   //
   // Example 4-42
   rand int unsigned min_len;
   rand int unsigned max_len;
       
   //
   // Constraints to always generate a valid frame
   //

   constraint eth_frame_valid {
      min_len <= max_len;
      data.size() == data_size;
   }

   constraint valid_untagged_frame {
      if (format == UNTAGGED) {
         len_typ != 16'h8808;
         len_typ != 16'h8100;
         min_len == ((len_typ >= 'h0600) ? 46 : 0);
         max_len == 1500;
      }
   }

   constraint valid_tagged_frame {
      if (format == TAGGED) {
         len_typ != 16'h8808;
         min_len == ((len_typ >= 'h0600) ? 44 : 0);
         max_len == 1500;
      }
   }

   constraint valid_control_frame {
      if (format == CONTROL) {
         len_typ == 16'h8808;
         min_len == max_len;
      }
   }

   constraint valid_opcode {
      opcode == PAUSE;                        
   }

   constraint no_control_frames {
      format != CONTROL;
   }
   

   // Example 4-38
   constraint valid_pause_frame {
      if (format == CONTROL && opcode == PAUSE) {
          dst     == 48'h0180C2000001;
          max_len == 42;
      }
   }

   // Example 4-34
   constraint valid_len_typ {
      (data.size() <= 1500 && len_typ == data.size()) ||
      len_typ >= 16'h0600;
   }

   constraint limit_data_size {
      data.size() < 65535;
   }

   // Example 4-43                      
   constraint interesting_data_size {
      data_size dist {min_len               :/ 1,
                      [min_len+1:max_len-1] :/ 1,
                      max_len               :/ 1};
   }

   // Example 4-37
   constraint valid_fcs {
      fcs == 32'h0000_0000;
   }

   // Example 4-47
   constraint test_constraints1;
   constraint test_constraints2;
   constraint test_constraints3;
  
`ifdef ETH_USE_COMPOSITION
   // Example 4-40
   function void pre_randomize();
      if (this.vlan == null) this.vlan = new;
   endfunction: pre_randomize
`endif

   function void post_randomize();
`ifdef ETH_USE_COMPOSITION
      if (format != TAGGED) this.vlan = null;
`endif
      this.data = new [this.data_size] (this.data);
      if (format == CONTROL) begin
         foreach (data[i]) data[i] = 8'h00;
      end
   endfunction: post_randomize

   
   //
   // Methods
   //

   // Example 4-33
   function new();
      super.new(this.log);
   endfunction: new
      
   extern virtual function vmm_data allocate();
   extern virtual function vmm_data copy(vmm_data to = null);
   extern virtual function bit compare(vmm_data      to,
                                       output string diff,
                                       input int     kind = -1);

   extern virtual function string psdisplay(string prefix = "");

   extern virtual function bit is_valid(bit silent = 1,
                                        int kind   = -1);


   extern virtual function int unsigned byte_size(int kind = -1);

   virtual function int unsigned max_byte_size(int kind = -1);
      max_byte_size = 1500;
   endfunction

   extern virtual function int unsigned byte_pack(ref logic [7:0]    bytes[],
                                                  input int unsigned offset = 0,
                                                  input int          kind   = -1);
   extern virtual function int unsigned byte_unpack(const ref logic [7:0] bytes[],
                                                    input int unsigned    offset = 0,
                                                    input int             len    = -1,
                                                    input int             kind   = -1);

   extern virtual function bit [31:0] compute_fcs();
endclass: eth_frame
     

`vmm_channel(eth_frame)
// Example 4-14
`vmm_atomic_gen(eth_frame, "Ethernet Frame")
`vmm_scenario_gen(eth_frame, "Ethernet Frame")


function vmm_data eth_frame::allocate();
   eth_frame i = new;
   allocate = i;
endfunction: allocate


function vmm_data eth_frame::copy(vmm_data to=null);
   eth_frame cpy;

   if (to != null) begin
      if (!$cast(cpy, to)) begin
         `vmm_error(this.log, "Cannot copy to non-eth_frame instance");
         return null;
       end
   end else cpy = new;

   super.copy_data(cpy);

   cpy.format        = this.format;
   cpy.dst           = this.dst;
   cpy.src           = this.src;
`ifdef ETH_USE_COMPOSITION
   if (this.vlan != null) begin
      cpy.vlan = new;
      cpy.vlan.user_priority = this.vlan.user_priority;
      cpy.vlan.cfi           = this.vlan.cfi;
      cpy.vlan.id            = this.vlan.id;
   end
`else
   cpy.user_priority = this.user_priority;
   cpy.cfi           = this.cfi;
   cpy.vlan_id       = this.vlan_id;
`endif
   cpy.len_typ       = this.len_typ;
   cpy.opcode        = this.opcode;
   cpy.pause_time    = this.pause_time;
   cpy.data          = this.data;

   copy = cpy;
endfunction: copy


function bit eth_frame::compare(vmm_data      to,
                                output string diff,
                                input int     kind=-1);
   eth_frame fr;
   int no_data = 0;

   compare = 0;
   if (to == null || !$cast(fr, to)) begin
      `vmm_error(this.log, "Cannot compare to non-eth_frame instance");
      return 0;
   end

   if (fr.format !== this.format) begin
      $sformat(diff, "format (%0s !== %0s)",
               this.format.name(), fr.format.name());
      return 0;
   end

   if (fr.dst !== this.dst) begin
      $sformat(diff, "dst (48'h%h !== 48'h%h)", this.dst, fr.dst);
      return 0;
   end

   if (fr.src !== this.src) begin
      $sformat(diff, "src (48'h%h !== 48'h%h)", this.src, fr.src);
      return 0;
   end

   if (fr.len_typ !== this.len_typ) begin
      if (this.len_typ >= 16'h0600) begin
         $sformat(diff, "len_typ (16'h%h !== 16'h%h)",
                  this.len_typ, fr.len_typ);
      end else begin
         $sformat(diff, "len_typ (16'd%0d !== 16'd%0d)",
                  this.len_typ, fr.len_typ);
      end
      return 0;
   end

   if (this.format == eth_frame::TAGGED) begin
`ifdef ETH_USE_COMPOSITION
      if (fr.vlan == null) begin
         diff = "No vlan data";
         return 0;
      end

      if (fr.vlan.user_priority !== this.vlan.user_priority) begin
         $sformat(diff, "user_priority (3'd%0d !== 3'd%0d)",
                  this.vlan.user_priority, fr.vlan.user_priority);
         return 0;
      end

      if (fr.vlan.cfi !== this.vlan.cfi) begin
         $sformat(diff, "cfi (1'b%b !== 1'b%b)", this.vlan.cfi, fr.vlan.cfi);
         return 0;
      end
      
      if (fr.vlan.id !== this.vlan.id) begin
         $sformat(diff, "vlan_id (12'h%h !== 12'h%h)",
                  this.vlan.id, fr.vlan.id);
         return 0;
      end
`else
      if (fr.user_priority !== this.user_priority) begin
         $sformat(diff, "user_priority (3'd%0d !== 3'd%0d)",
                  this.user_priority, fr.user_priority);
         return 0;
      end

      if (fr.cfi !== this.cfi) begin
         $sformat(diff, "cfi (1'b%b !== 1'b%b)", this.cfi, fr.cfi);
         return 0;
      end
      
      if (fr.vlan_id !== this.vlan_id) begin
         $sformat(diff, "vlan_id (12'h%h !== 12'h%h)",
                  this.vlan_id, fr.vlan_id);
         return 0;
      end
`endif
   end

   if (this.format == eth_frame::CONTROL) begin
      if (fr.opcode !== this.opcode) begin
         $sformat(diff, "opcode (%0s !== %0s)", this.opcode, fr.opcode);
         return 0;
      end

      if (this.opcode == eth_frame::PAUSE) begin
         if (fr.pause_time !== this.pause_time) begin
            $sformat(diff, "pause_time (16'd%0d !== 16'd%0d)",
                     this.pause_time, fr.pause_time);
            return 0;
         end
         no_data = 1;
      end
   end

   if (!no_data) begin
      if (fr.data.size() !== this.data.size()) begin
         $sformat(diff, "data.size() (16'd%0d !== 16'd%0d)",
                  this.data.size(), fr.data.size());
         return 0;
      end
      foreach (this.data[i]) begin
         if (fr.data[i] !== this.data[i]) begin
            $sformat(diff, "data[%0d] (8'h%h !== 8'h%h)",
                     i, this.data[i], fr.data[i]);
            return 0;
         end
      end
   end

   // For FCS, we only care whether they indicate valid or not
   if ((fr.fcs === 32'h0000_0000) !== (this.fcs === 32'h0000_0000)) begin
      $sformat(diff, "FCS (%0s !== %0s)",
               (fr.fcs === 32'h0000_0000) ? "valid" : "invalid",
               (this.fcs === 32'h0000_0000) ? "valid" : "invalid");
      return 0;
   end
   compare = 1;
endfunction: compare


// Example 4-39       
function string eth_frame::psdisplay(string prefix="");
   bit no_data = 0;
       
   $sformat(psdisplay, "%sEthernet Frame #%0d.%0d.%0d:\n", prefix,
            this.stream_id, this.scenario_id, this.data_id);
   $sformat(psdisplay, "%s%s   dst=48'h%h, src=48'h%h, len/typ=16'h%h\n",
            psdisplay, prefix, this.dst, this.src, this.len_typ);

   case (this.format)

   TAGGED: begin
      $sformat(psdisplay, "%s%s   (tagged) pri=3'd%0d cfi=%b vlan=12'h%h\n",
               psdisplay, prefix,
`ifdef ETH_USE_COMPOSITION
               this.vlan.user_priority, this.vlan.cfi, this.vlan.id);
`else
               this.user_priority, this.cfi, this.vlan_id);
`endif
   end

   CONTROL: begin
      case (this.opcode)
      PAUSE: begin
         $sformat(psdisplay, "%s%s   PAUSE for %0d quantas\n",
                psdisplay, prefix, this.pause_time);
         no_data = 1;
      end
      default: begin
         $sformat(psdisplay, "%s%s   opcode=16'h%h\n",
                  psdisplay, prefix, this.opcode);
      end
      endcase
   end
   endcase

   if (!no_data) begin
      int i;

      $sformat(psdisplay, "%s%s   len=%0d, data=", psdisplay, prefix,
               data.size());
      for (i = 0; i < data.size(); i++) begin
         $sformat(psdisplay, "%s 0x%h", psdisplay, this.data[i]);
         if (this.data.size() > 8 && i == 5) begin
            $sformat(psdisplay, "%s ..", psdisplay);
            i = this.data.size() - 3;
         end
      end
      $sformat(psdisplay, "%s\n", psdisplay);
   end

   $sformat(psdisplay, "%s%s   FCS is %0s", psdisplay, prefix,
            (fcs) ? "BAD" : "good");
endfunction: psdisplay


function bit eth_frame::is_valid(bit silent=1,
                                 int kind=-1);
   is_valid = 1; /*this.randomize(null);*/
   if (!is_valid && !silent) begin
      `vmm_error(this.log, "Frame is not valid");
   end
endfunction: is_valid


function int unsigned eth_frame::byte_size(int kind=-1);
   byte_size = 14 + data.size();
   if (format == TAGGED) byte_size += 4;
endfunction: byte_size


function int unsigned eth_frame::byte_pack(ref logic [7:0]    bytes[],
                                           input int unsigned offset=0,
                                           input int          kind=-1);
   int i;

   if (bytes.size() < offset + this.byte_size(kind)) begin
      bytes = new [offset + this.byte_size(kind)] (bytes);
   end

   i = offset;
   {bytes[i  ], bytes[i+1], bytes[i+2], bytes[i+3], bytes[i+ 4], bytes[i+ 5]} = this.dst;
   {bytes[i+6], bytes[i+7], bytes[i+8], bytes[i+9], bytes[i+10], bytes[i+11]} = this.src;
   i += 12;

   case (this.format)
   UNTAGGED: begin
      {bytes[i], bytes[i+1]} = this.len_typ;
      i += 2;
   end

   TAGGED: begin
      {bytes[i], bytes[i+1]} = 16'h8100;
      i += 2;
`ifdef ETH_USE_COMPOSITION
      {bytes[i], bytes[i+1]} = {this.vlan.user_priority, this.vlan.cfi, this.vlan.id};
`else
      {bytes[i], bytes[i+1]} = {this.user_priority, this.cfi, this.vlan_id};
`endif
      i += 2;
      {bytes[i], bytes[i+1]} = this.len_typ;
      i += 2;
   end

   // Example 4-38
   CONTROL: begin
      {bytes[i], bytes[i+1]} = 16'h8808;
      i += 2;
      {bytes[i], bytes[i+1]} = this.opcode;
      i += 2;

      case (this.opcode)
      PAUSE: begin
         {bytes[i], bytes[i+1]} = this.pause_time;
         i += 2;
      end
      endcase
   end
   endcase

   foreach (this.data[j]) begin
      bytes[i++] = this.data[j];
   end

   byte_pack = i - offset;
endfunction: byte_pack


function int unsigned eth_frame::byte_unpack(const ref logic [7:0] bytes[],
                                             input int unsigned    offset=0,
                                             input int             len=-1,
                                             input int             kind=-1);
   int bytes_len;
   int i, j, k;
   int no_data = 0;

   // Invalidate this instance to make sure we
   // do not have left-over data from a previous instance
   // in case of not enough data supplied
   this.dst           = 48'hx;
   this.src           = 48'hx;
`ifdef ETH_USE_COMPOSITION
   this.vlan          = null;
`else
   this.user_priority = 3'bx;
   this.cfi           = 1'bx;
   this.vlan_id       = 12'hx;
`endif
   this.len_typ       = 16'hx;
   this.opcode        = 16'hx;
   this.pause_time    = 16'hx;
   this.data          = new [0];
   this.fcs           = 32'hXXXX_XXXX;

   bytes_len = bytes.size();
   if (len > 0) begin
      bytes_len = len + offset;
      if (bytes_len > bytes.size()) bytes_len = bytes.size();
   end

   i = offset;
   byte_unpack = 0;

   this.fcs = 32'hx;
   // Assume untagged data frame by default
   this.format = eth_frame::UNTAGGED;

   // Unpack the dst and src addresses
   for (k = 0; i < bytes_len && k < 6; k++) begin
      this.dst[47-k*8 -:8] = bytes[i];
      i++;
      byte_unpack++;
   end
   if (i >= bytes_len) return byte_unpack;
   for (k = 0; i < bytes_len && k < 6; k++) begin
      this.src[47-k*8 -:8] = bytes[i];
      i++;
      byte_unpack++;
   end
   if (i >= bytes_len) return byte_unpack;

   // Is this a tagged frame?
   if (i+1 >= bytes_len) return byte_unpack;
   // Example 4-41
   if ({bytes[i], bytes[i+1]} == 16'h8100) begin
      this.format = eth_frame::TAGGED;
`ifdef ETH_USE_COMPOSITION
      this.vlan = new;
`endif
      i += 2;
      byte_unpack += 2;
      if (i+1 >= bytes_len) return byte_unpack;
`ifdef ETH_USE_COMPOSITION
      {this.vlan.user_priority, this.vlan.cfi, this.vlan.id} = {bytes[i], bytes[i+1]};
`else
      {this.user_priority, this.cfi, this.vlan_id} = {bytes[i], bytes[i+1]};
`endif
      i += 2;
      byte_unpack += 2;
      if (i+1 >= bytes_len) return byte_unpack;
      this.len_typ = {bytes[i], bytes[i+1]};
      i += 2;
      byte_unpack += 2;
   end else if ({bytes[i], bytes[i+1]} == 16'h8808) begin
      this.len_typ = 16'h8808;
      this.format = eth_frame::CONTROL;
      i += 2;
      byte_unpack += 2;
      if (i+1 >= bytes_len) return byte_unpack;
      this.opcode = {bytes[i], bytes[i+1]};
      i += 2;
      byte_unpack += 2;
      case (this.opcode)
         PAUSE: begin
            if (i+1 >= bytes_len) return byte_unpack;
            this.pause_time = {bytes[i], bytes[i+1]};
            i += 2;
            byte_unpack += 2;
            no_data = 1;
         end
      endcase
   end else begin
      this.len_typ = {bytes[i], bytes[i+1]};
      i += 2;
      byte_unpack += 2;
   end

   if (i >= bytes_len) return byte_unpack;
   if (no_data == 0) begin
      int l = (this.len_typ >= 'h0600 ||
               this.len_typ > bytes_len - i) ? bytes_len - i : this.len_typ;
      this.data = new [l];
   
      foreach (this.data[k]) begin
         this.data[k] = bytes[i];
         i++;
         byte_unpack++;
      end
   end

   this.fcs = 32'hx;
endfunction: byte_unpack


// Example 4-37
function bit [31:0] eth_frame::compute_fcs();
   logic [7:0] bytes[];

   void'(this.byte_pack(bytes));
   compute_fcs = this.utils.compute_crc32(bytes, 0, bytes.size() - 4);
endfunction: compute_fcs


